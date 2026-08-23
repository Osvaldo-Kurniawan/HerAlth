import 'dart:typed_data';
import 'dart:ui' as ui;

class UltrasoundValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? mimeType;

  const UltrasoundValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.mimeType,
  });

  const UltrasoundValidationResult.valid(String mimeType)
    : this._(isValid: true, mimeType: mimeType);

  const UltrasoundValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

class UltrasoundValidator {
  static const maxBytes = 10 * 1024 * 1024;
  static const minImageDimension = 160;

  Future<UltrasoundValidationResult> validate({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) {
      return const UltrasoundValidationResult.invalid(
        'This file is empty. Please choose a real ultrasound image or PDF.',
      );
    }
    if (bytes.length > maxBytes) {
      return const UltrasoundValidationResult.invalid(
        'This file is larger than 10 MB. Please choose a smaller scan.',
      );
    }

    final extension = _extensionOf(fileName);
    if (!{'jpg', 'jpeg', 'png', 'pdf'}.contains(extension)) {
      return const UltrasoundValidationResult.invalid(
        'Only JPG, PNG, or PDF ultrasound files are supported.',
      );
    }

    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'pdf' => 'application/pdf',
      _ => null,
    };
    if (mimeType == null || !_matchesSignature(extension, bytes)) {
      return const UltrasoundValidationResult.invalid(
        'The file content does not match its extension. Please select the original export.',
      );
    }

    if (extension == 'pdf') return UltrasoundValidationResult.valid(mimeType);

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final isLargeEnough =
          frame.image.width >= minImageDimension &&
          frame.image.height >= minImageDimension;
      frame.image.dispose();
      codec.dispose();
      if (!isLargeEnough) {
        return const UltrasoundValidationResult.invalid(
          'This image is too small to review. Please upload the original scan.',
        );
      }
    } catch (_) {
      return const UltrasoundValidationResult.invalid(
        'We could not read this image. Please export the ultrasound again as JPG or PNG.',
      );
    }

    return UltrasoundValidationResult.valid(mimeType);
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot == -1 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  bool _matchesSignature(String extension, Uint8List bytes) {
    if (extension == 'pdf') {
      return bytes.length >= 5 &&
          String.fromCharCodes(bytes.take(5)) == '%PDF-';
    }
    if (extension == 'png') {
      const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      return bytes.length >= signature.length && _startsWith(bytes, signature);
    }
    return bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
  }

  bool _startsWith(Uint8List bytes, List<int> signature) {
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    return true;
  }
}
