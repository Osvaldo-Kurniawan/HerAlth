import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/core/validation/ultrasound_validator.dart';

void main() {
  final validator = UltrasoundValidator();

  group('UltrasoundValidator', () {
    test('rejects an empty file', () async {
      final result = await validator.validate(
        fileName: 'scan.png',
        bytes: Uint8List(0),
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('empty'));
    });

    test('rejects files larger than 10 MB', () async {
      final result = await validator.validate(
        fileName: 'scan.png',
        bytes: Uint8List(UltrasoundValidator.maxBytes + 1),
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('10 MB'));
    });

    test('rejects an unsupported extension', () async {
      final result = await validator.validate(
        fileName: 'scan.gif',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('JPG, PNG, or PDF'));
    });

    test('rejects a renamed non-image file', () async {
      final result = await validator.validate(
        fileName: 'scan.jpg',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('does not match'));
    });

    test('accepts a PDF with a valid PDF signature', () async {
      final result = await validator.validate(
        fileName: 'ultrasound.pdf',
        bytes: Uint8List.fromList('%PDF-1.7\n'.codeUnits),
      );

      expect(result.isValid, isTrue);
      expect(result.mimeType, 'application/pdf');
    });

    test('rejects a corrupted PNG after signature validation', () async {
      final result = await validator.validate(
        fileName: 'scan.png',
        bytes: Uint8List.fromList([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
        ]),
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('read'));
    });
  });
}
