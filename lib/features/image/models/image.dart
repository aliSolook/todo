import 'dart:typed_data';

class Image {
  final String title;
  final Uint8List data;

  const Image({
    required this.title,
    required this.data,
  });
}
