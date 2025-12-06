import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/models/image.dart';
import 'package:dart_either/dart_either.dart';

abstract class ImageRepository {
  Future<Either<String, List<ImageWrapper>>> listImages();
  Future<Either<String, Image>> getImage(dynamic id);
  Future<Either<String, String>> getTitle(dynamic id);
  Future<Either<String, dynamic>> addImage(Image image);
  Future<Either<String, String>> deleteImage(dynamic id);
  Future<Either<String, String>> updateImage(dynamic id, Image image);
}
