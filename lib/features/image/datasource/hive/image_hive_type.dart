import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:todo/features/image/image.dart';

part 'image_hive_type.g.dart';

@HiveType(typeId: 3)
class ImageHiveType {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final Uint8List data;

  const ImageHiveType({
    required this.title,
    required this.data,
  });

  factory ImageHiveType.fromImage(Image image) =>
      ImageHiveType(title: image.title, data: image.data);

  Image toImage() => Image(title: title, data: data);

  ImageWrapper wrap(dynamic id) => ImageWrapper(id: id, title: title);
}
