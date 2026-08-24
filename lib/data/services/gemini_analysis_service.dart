import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../domain/models/check_up_analysis.dart';
import '../../domain/models/ultrasound_attachment.dart';
import '../../domain/services/check_up_analysis_service.dart';

class GeminiAnalysisException implements Exception {
  final String message;
  final int? statusCode;
  final String? apiMessage;
  final String? apiStatus;
  final String? model;
  final String? responseBody;
  final GeminiAnalysisException? previousFailure;

  const GeminiAnalysisException(
    this.message, {
    this.statusCode,
    this.apiMessage,
    this.apiStatus,
    this.model,
    this.responseBody,
    this.previousFailure,
  });

  bool get isRetryable =>
      statusCode == 408 ||
      statusCode == 429 ||
      (statusCode != null && statusCode! >= 500 && statusCode! <= 599);

  String get diagnosticMessage {
    final details = <String>[
      message,
      if (statusCode != null) 'HTTP $statusCode',
      if (model != null) 'model=$model',
      if (apiStatus != null) 'status=$apiStatus',
      if (apiMessage != null) 'api_message=$apiMessage',
      if (previousFailure != null)
        'previous_failure=(${previousFailure!.diagnosticMessage})',
    ];
    return details.join(' | ');
  }

  @override
  String toString() => 'GeminiAnalysisException: $diagnosticMessage';
}

class InvalidUltrasoundException extends GeminiAnalysisException {
  const InvalidUltrasoundException(super.message);
}

class GeminiAnalysisService implements CheckUpAnalysisService {
  final http.Client _client;
  final String Function() _apiKeyProvider;
  final String Function() _modelProvider;
  final String Function() _fallbackModelProvider;
  final Future<void> Function(Duration duration) _delay;
  final int _maxRetries;

  GeminiAnalysisService({
    http.Client? client,
    String Function()? apiKeyProvider,
    String Function()? modelProvider,
    String Function()? fallbackModelProvider,
    Future<void> Function(Duration duration)? delay,
    int maxRetries = 3,
  }) : _client = client ?? http.Client(),
       _apiKeyProvider = apiKeyProvider ?? (() => AppConfig.geminiApiKey),
       _modelProvider = modelProvider ?? (() => AppConfig.geminiModel),
       _fallbackModelProvider =
           fallbackModelProvider ?? (() => AppConfig.geminiFallbackModel),
       _delay = delay ?? ((duration) => Future<void>.delayed(duration)),
       _maxRetries = maxRetries,
       assert(maxRetries >= 0);

  @override
  Future<CheckUpAnalysis> analyze({
    required List<String> symptoms,
    required String notes,
    required CycleContextSnapshot cycleContext,
    UltrasoundAttachment? ultrasound,
  }) async {
    final apiKey = _apiKeyProvider().trim();
    if (apiKey.isEmpty) {
      throw const GeminiAnalysisException(
        'Gemini is not configured. Add GEMINI_API_KEY to .env or pass --dart-define.',
      );
    }

    final parts = <Map<String, Object>>[
      {'text': _prompt(symptoms, notes, cycleContext, ultrasound != null)},
    ];
    if (ultrasound != null) {
      parts.add({
        'inline_data': {
          'mime_type': ultrasound.mimeType,
          'data': base64Encode(ultrasound.bytes),
        },
      });
    }

    final requestBody = jsonEncode({
      'contents': [
        {'role': 'user', 'parts': parts},
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      },
    });
    final primaryModel = _modelProvider().trim();
    final fallbackModel = _fallbackModelProvider().trim();

    http.Response response;
    try {
      response = await _requestModel(
        model: primaryModel,
        apiKey: apiKey,
        body: requestBody,
        maxRetries: _maxRetries,
      );
    } on GeminiAnalysisException catch (primaryFailure) {
      final canFallback =
          primaryFailure.isRetryable &&
          fallbackModel.isNotEmpty &&
          fallbackModel != primaryModel;
      if (!canFallback) rethrow;

      try {
        response = await _requestModel(
          model: fallbackModel,
          apiKey: apiKey,
          body: requestBody,
          maxRetries: 0,
        );
      } on GeminiAnalysisException catch (fallbackFailure) {
        throw GeminiAnalysisException(
          fallbackFailure.message,
          statusCode: fallbackFailure.statusCode,
          apiMessage: fallbackFailure.apiMessage,
          apiStatus: fallbackFailure.apiStatus,
          model: fallbackFailure.model,
          responseBody: fallbackFailure.responseBody,
          previousFailure: primaryFailure,
        );
      }
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _responseText(responseJson);
    final analysisJson = _decodeJsonObject(text);
    final analysis = CheckUpAnalysis.fromJson(analysisJson, rawText: text);
    if (ultrasound != null && !analysis.isValidUltrasound) {
      throw const InvalidUltrasoundException(
        'This does not look like a supported ultrasound scan. Please upload a clear clinical ultrasound image or PDF.',
      );
    }
    return analysis;
  }

  Future<http.Response> _requestModel({
    required String model,
    required String apiKey,
    required String body,
    required int maxRetries,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '${Uri.encodeComponent(model)}:generateContent',
    );

    for (var attempt = 0; ; attempt++) {
      final http.Response response;
      try {
        response = await _client
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': apiKey,
              },
              body: body,
            )
            .timeout(const Duration(seconds: 60));
      } on TimeoutException {
        throw GeminiAnalysisException(
          'The AI request timed out. Please try again.',
          model: model,
        );
      } on http.ClientException catch (error) {
        throw GeminiAnalysisException(
          'The AI service could not be reached. Check your connection and try again.',
          apiMessage: error.message,
          model: model,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      final failure = _failureFromResponse(response, model);
      if (!failure.isRetryable || attempt >= maxRetries) throw failure;
      await _delay(Duration(seconds: 1 << attempt));
    }
  }

  GeminiAnalysisException _failureFromResponse(
    http.Response response,
    String model,
  ) {
    final apiError = _ApiError.fromBody(response.body);
    final message = switch (response.statusCode) {
      408 => 'The AI request timed out. Please try again.',
      429 => 'The AI service is busy right now. Please try again shortly.',
      >= 500 && <= 599 =>
        'The AI service is temporarily unavailable. Please try again shortly.',
      401 ||
      403 => 'Gemini authorization failed. Check the API key configuration.',
      _ =>
        'Our AI could not complete the analysis (${response.statusCode}). Please try again.',
    };
    return GeminiAnalysisException(
      message,
      statusCode: response.statusCode,
      apiMessage: apiError.message,
      apiStatus: apiError.status,
      model: model,
      responseBody: response.body,
    );
  }

  String _prompt(
    List<String> symptoms,
    String notes,
    CycleContextSnapshot cycleContext,
    bool hasUltrasound,
  ) {
    return '''You are HerAlth, a cautious women's-health information assistant.
This is not a diagnosis. Use only the supplied self-reported data and clearly recommend discussion with a healthcare professional.
${hasUltrasound ? 'First inspect the attached file. Set is_valid_ultrasound to false for unrelated photos, selfies, screenshots, blank files, unreadable files, or anything that is not a clinical ultrasound image/report. Do not infer medical findings from a non-ultrasound file.' : 'No ultrasound is attached.'}

Symptoms: ${symptoms.join(', ')}
Additional notes: ${notes.isEmpty ? '(none)' : notes}
Cycle context: ${jsonEncode(cycleContext.toJson())}

Return JSON only with this exact shape:
{
  "is_valid_ultrasound": true,
  "attention": "ATTENTION SUGGESTED",
  "headline": "Patterns worth discussing",
  "summary": "A short non-diagnostic summary.",
  "signal_strength": "Moderate",
  "signal_percent": 55,
  "observed_signals": [{"title":"Irregular cycle length","detail":"A brief evidence-based detail.","icon":"calendar"}],
  "possible_explanations": [{"name":"Possible explanation","tag":"DISCUSS","description":"A cautious explanation, not a diagnosis."}]
}
Use at most 4 observed signals and 3 possible explanations. Never claim certainty, never recommend treatment, and never invent an ultrasound finding.''';
  }

  String _responseText(Map<String, dynamic> responseJson) {
    final candidates = responseJson['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GeminiAnalysisException('Gemini returned an empty analysis.');
    }
    final candidate = candidates.first;
    if (candidate is! Map) {
      throw const GeminiAnalysisException(
        'Gemini returned an unreadable analysis.',
      );
    }
    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List) {
      throw const GeminiAnalysisException(
        'Gemini returned an unreadable analysis.',
      );
    }
    final textPart = parts.whereType<Map>().firstWhere(
      (part) => part['text'] is String,
      orElse: () => <String, Object>{},
    );
    final text = textPart['text'];
    if (text is! String || text.trim().isEmpty) {
      throw const GeminiAnalysisException('Gemini returned an empty analysis.');
    }
    return text.trim();
  }

  Map<String, dynamic> _decodeJsonObject(String text) {
    final cleaned = text
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start >= 0 && end > start) {
        final decoded = jsonDecode(cleaned.substring(start, end + 1));
        if (decoded is Map<String, dynamic>) return decoded;
      }
    }
    throw const GeminiAnalysisException(
      'Gemini returned an invalid analysis format.',
    );
  }
}

class _ApiError {
  final String? message;
  final String? status;

  const _ApiError({this.message, this.status});

  factory _ApiError.fromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return const _ApiError();
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) return const _ApiError();
      return _ApiError(
        message: error['message'] is String ? error['message'] as String : null,
        status: error['status'] is String ? error['status'] as String : null,
      );
    } on FormatException {
      return const _ApiError();
    }
  }
}
