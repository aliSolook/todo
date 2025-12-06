import 'package:dart_either/dart_either.dart';
import 'package:todo/features/image/datasource/image_datasource.dart';
import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/models/image.dart';
import 'package:todo/features/image/repository/image_repository.dart';
import 'package:todo/di/di.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageDatasource _source = locator.get();
  final Duration? _delay;

  ImageRepositoryImpl([Duration? delay]) : _delay = delay;

  @override
  Future<Either<String, dynamic>> addImage(Image image) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.addImage(image));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> deleteImage(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.deleteImage(id);
      return const Right('عکس با موفقیت حذف شد');
    } on ImageNotFoundException {
      return const Left('عکس وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, Image>> getImage(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.getImage(id));
    } on ImageNotFoundException {
      return const Left('عکس وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> getTitle(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    return _source
        .getTitle(id)
        .toEitherFuture(
          (error, stackTrace) => error is ImageNotFoundException
              ? 'عکس وجود ندارد'
              : 'خطایی رخ داد',
        );
  }

  @override
  Future<Either<String, List<ImageWrapper>>> listImages() async {
    if (_delay != null) await Future.delayed(_delay);
    return _source.listImages().toEitherFuture(
      (error, stackTrace) => 'خطایی رخ داد',
    );
  }

  @override
  Future<Either<String, String>> updateImage(dynamic id, Image image) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.updateImage(id, image);
      return const Right('عکس با موفقیت ویرایش شد');
    } on ImageNotFoundException {
      return const Left('عکس وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }
}
