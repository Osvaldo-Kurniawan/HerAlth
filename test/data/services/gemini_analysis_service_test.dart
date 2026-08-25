import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/services/gemini_analysis_service.dart';
import 'package:heralth/domain/models/check_up_analysis.dart';
import 'package:heralth/domain/models/ultrasound_attachment.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const cycle = CycleContextSnapshot.defaults();
  final ultrasound = UltrasoundAttachment(
    name: 'scan.pdf',
    bytes: Uint8List.fromList([37, 80, 68, 70, 45]),
    mimeType: 'application/pdf',
  );

  test('sends the multimodal payload and parses Gemini JSON', () async {
    final client = MockClient((request) async {
      expect(request.headers['x-goog-api-key'], 'test-key');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final content = (body['contents'] as List).first as Map<String, dynamic>;
      final parts = content['parts'] as List;
      final imagePart = parts[1] as Map<String, dynamic>;
      final inlineData = imagePart['inline_data'] as Map<String, dynamic>;
      expect(inlineData['mime_type'], 'application/pdf');

      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': jsonEncode({
                      'is_valid_ultrasound': true,
                      'attention': 'ATTENTION SUGGESTED',
                      'headline': 'Patterns worth discussing',
                      'summary': 'A cautious summary.',
                      'signal_strength': 'Moderate',
                      'signal_percent': 55,
                      'observed_signals': [],
                      'possible_explanations': [],
                    }),
                  },
                ],
              },
            },
          ],
        }),
        200,
      );
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-test',
    );

    final result = await service.analyze(
      symptoms: const ['Fatigue'],
      notes: '',
      cycleContext: cycle,
      ultrasound: ultrasound,
    );

    expect(result.headline, 'Patterns worth discussing');
    expect(result.signalPercent, 55);
  });

  test('rejects an ultrasound Gemini marks as unrelated', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': '{"is_valid_ultrasound":false}'},
                ],
              },
            },
          ],
        }),
        200,
      );
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-test',
    );

    expect(
      () => service.analyze(
        symptoms: const ['Fatigue'],
        notes: '',
        cycleContext: cycle,
        ultrasound: ultrasound,
      ),
      throwsA(isA<InvalidUltrasoundException>()),
    );
  });

  for (final statusCode in <int>[408, 429, 500, 503]) {
    test('retries HTTP $statusCode and succeeds on the next attempt', () async {
      var requestCount = 0;
      final delays = <Duration>[];
      final client = MockClient((_) async {
        requestCount++;
        return requestCount == 1
            ? _errorResponse(statusCode, message: 'Temporary failure')
            : _successResponse();
      });
      final service = GeminiAnalysisService(
        client: client,
        apiKeyProvider: () => 'test-key',
        modelProvider: () => 'gemini-primary',
        fallbackModelProvider: () => 'gemini-primary',
        maxRetries: 1,
        delay: (duration) async => delays.add(duration),
      );

      final result = await _analyze(service, cycle);

      expect(result.headline, 'Patterns worth discussing');
      expect(requestCount, 2);
      expect(delays, const <Duration>[Duration(seconds: 1)]);
    });
  }

  test('uses exponential backoff before trying the fallback model', () async {
    final requestedModels = <String>[];
    final delays = <Duration>[];
    final client = MockClient((request) async {
      requestedModels.add(request.url.pathSegments[2]);
      if (request.url.path.contains('gemini-primary')) {
        return _errorResponse(503, message: 'Primary model overloaded');
      }
      return _successResponse();
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-primary',
      fallbackModelProvider: () => 'gemini-3.5-flash',
      maxRetries: 3,
      delay: (duration) async => delays.add(duration),
    );

    final result = await _analyze(service, cycle);

    expect(result.headline, 'Patterns worth discussing');
    expect(requestedModels, const <String>[
      'gemini-primary:generateContent',
      'gemini-primary:generateContent',
      'gemini-primary:generateContent',
      'gemini-primary:generateContent',
      'gemini-3.5-flash:generateContent',
    ]);
    expect(delays, const <Duration>[
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ]);
  });

  test(
    'retries request timeouts and falls back to the secondary model',
    () async {
      final requestedModels = <String>[];
      final delays = <Duration>[];
      final client = MockClient((request) async {
        requestedModels.add(request.url.pathSegments[2]);
        if (request.url.path.contains('gemini-primary')) {
          throw TimeoutException('simulated request timeout');
        }
        return _successResponse();
      });
      final service = GeminiAnalysisService(
        client: client,
        apiKeyProvider: () => 'test-key',
        modelProvider: () => 'gemini-primary',
        fallbackModelProvider: () => 'gemini-3.5-flash',
        maxRetries: 3,
        requestTimeout: const Duration(milliseconds: 1),
        delay: (duration) async => delays.add(duration),
      );

      final result = await _analyze(service, cycle);

      expect(result.headline, 'Patterns worth discussing');
      expect(requestedModels, const <String>[
        'gemini-primary:generateContent',
        'gemini-primary:generateContent',
        'gemini-primary:generateContent',
        'gemini-primary:generateContent',
        'gemini-3.5-flash:generateContent',
      ]);
      expect(delays, const <Duration>[
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ]);
    },
  );

  test('reports an exhausted timeout as retryable HTTP 408', () async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      throw TimeoutException('simulated request timeout');
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-primary',
      fallbackModelProvider: () => 'gemini-primary',
      maxRetries: 1,
      requestTimeout: const Duration(milliseconds: 1),
      delay: (_) async {},
    );

    await expectLater(
      _analyze(service, cycle),
      throwsA(
        isA<GeminiAnalysisException>()
            .having((error) => error.statusCode, 'statusCode', 408)
            .having((error) => error.isRetryable, 'isRetryable', isTrue),
      ),
    );
    expect(requestCount, 2);
  });

  test('does not retry or fallback for a non-retryable status', () async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      return _errorResponse(400, message: 'Invalid request payload');
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-primary',
      fallbackModelProvider: () => 'gemini-3.5-flash',
      delay: (_) async => fail('A non-retryable error must not wait.'),
    );

    await expectLater(
      _analyze(service, cycle),
      throwsA(
        isA<GeminiAnalysisException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having(
              (error) => error.apiMessage,
              'apiMessage',
              'Invalid request payload',
            )
            .having((error) => error.model, 'model', 'gemini-primary')
            .having(
              (error) => error.responseBody,
              'responseBody',
              contains('Invalid request payload'),
            ),
      ),
    );
    expect(requestCount, 1);
  });

  test('preserves primary and fallback API errors for diagnosis', () async {
    final client = MockClient((request) async {
      if (request.url.path.contains('gemini-primary')) {
        return _errorResponse(
          503,
          message: 'Primary model overloaded',
          status: 'UNAVAILABLE',
        );
      }
      return _errorResponse(
        429,
        message: 'Fallback quota exhausted',
        status: 'RESOURCE_EXHAUSTED',
      );
    });
    final service = GeminiAnalysisService(
      client: client,
      apiKeyProvider: () => 'test-key',
      modelProvider: () => 'gemini-primary',
      fallbackModelProvider: () => 'gemini-3.5-flash',
      maxRetries: 1,
      delay: (_) async {},
    );

    await expectLater(
      _analyze(service, cycle),
      throwsA(
        isA<GeminiAnalysisException>()
            .having((error) => error.statusCode, 'fallback statusCode', 429)
            .having(
              (error) => error.apiMessage,
              'fallback apiMessage',
              'Fallback quota exhausted',
            )
            .having(
              (error) => error.previousFailure?.statusCode,
              'primary statusCode',
              503,
            )
            .having(
              (error) => error.previousFailure?.apiMessage,
              'primary apiMessage',
              'Primary model overloaded',
            )
            .having(
              (error) => error.diagnosticMessage,
              'diagnosticMessage',
              allOf(contains('RESOURCE_EXHAUSTED'), contains('UNAVAILABLE')),
            ),
      ),
    );
  });
}

Future<CheckUpAnalysis> _analyze(
  GeminiAnalysisService service,
  CycleContextSnapshot cycle,
) {
  return service.analyze(
    symptoms: const <String>['Fatigue'],
    notes: '',
    cycleContext: cycle,
  );
}

http.Response _successResponse() {
  return http.Response(
    jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {
                'text': jsonEncode({
                  'is_valid_ultrasound': true,
                  'attention': 'ATTENTION SUGGESTED',
                  'headline': 'Patterns worth discussing',
                  'summary': 'A cautious summary.',
                  'signal_strength': 'Moderate',
                  'signal_percent': 55,
                  'observed_signals': <Object>[],
                  'possible_explanations': <Object>[],
                }),
              },
            ],
          },
        },
      ],
    }),
    200,
  );
}

http.Response _errorResponse(
  int statusCode, {
  required String message,
  String status = 'ERROR',
}) {
  return http.Response(
    jsonEncode({
      'error': {'code': statusCode, 'message': message, 'status': status},
    }),
    statusCode,
  );
}
