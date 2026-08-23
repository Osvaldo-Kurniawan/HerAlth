import 'dart:typed_data';

class UltrasoundAttachment {
  final String name;
  final Uint8List bytes;
  final String mimeType;

  const UltrasoundAttachment({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  int get sizeBytes => bytes.length;
  bool get isPdf => mimeType == 'application/pdf';
}
