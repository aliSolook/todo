import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'image.dart';

class ImageWrapper extends Equatable {
  final dynamic id;
  final String title;

  const ImageWrapper({
    required this.id,
    required this.title,
  });

  Image toImage(Uint8List data) => Image(title: title, data: data);

  @override
  String toString() {
    return 'ImageWrapper($id, $title)';
  }

  @override
  List<Object?> get props => [id, title];
}
