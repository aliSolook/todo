import 'package:todo/features/image/models/image_wrapper.dart';
import '../models/image.dart';

abstract class ImageDatasource {
  Future<List<ImageWrapper>> listImages();
  Future<Image> getImage(dynamic id);
  Future<String> getTitle(dynamic id);
  Future<dynamic> addImage(Image image);
  Future<void> deleteImage(dynamic id);
  Future<void> updateImage(dynamic id, Image image);
}

class ImageNotFoundException implements Exception {
  final dynamic id;

  ImageNotFoundException(this.id);

  @override
  String toString() {
    return 'ImageNotFoundException($id)';
  }
}
