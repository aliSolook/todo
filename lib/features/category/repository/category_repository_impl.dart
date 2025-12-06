import 'package:dart_either/dart_either.dart';
import 'package:todo/features/category/models/category_wrapper.dart';
import 'package:todo/features/category/models/category.dart';
import 'package:todo/features/category/repository/category_repository.dart';
import 'package:todo/features/category/datasource/category_datasource.dart';
import 'package:todo/di/di.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource _source = locator.get();
  final Duration? _delay;

  CategoryRepositoryImpl([Duration? delay]) : _delay = delay;

  @override
  Future<Either<String, int>> addCategory(Category category) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.addCategory(category));
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> deleteCategory(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.deleteCategory(id);
      return const Right('دسته‌بندی با موفقیت حذف شد');
    } on CategoryNotFoundException {
      return const Left('دسته‌‌بندی وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, CategoryWrapper>> getCategory(dynamic id) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.getCategory(id));
    } on CategoryNotFoundException {
      return const Left('دسته‌‌بندی وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, List<CategoryWrapper>>> listCategories() async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      return Right(await _source.listCategories());
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }

  @override
  Future<Either<String, String>> updateCategory(
    CategoryWrapper categoryWrapper,
  ) async {
    if (_delay != null) await Future.delayed(_delay);
    try {
      await _source.updateCategory(categoryWrapper);
      return const Right('دسته‌بندی با موفقیت ویرایش شد');
    } on CategoryNotFoundException {
      return const Left('دسته‌‌بندی وجود ندارد');
    } catch (e) {
      return const Left('خطایی رخ داد');
    }
  }
}
