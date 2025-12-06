import 'package:todo/features/category/models/category_wrapper.dart';
import 'package:todo/features/category/models/category.dart';
import 'package:dart_either/dart_either.dart';

abstract class CategoryRepository {
  Future<Either<String, List<CategoryWrapper>>> listCategories();
  Future<Either<String, CategoryWrapper>> getCategory(dynamic id);
  Future<Either<String, dynamic>> addCategory(Category category);
  Future<Either<String, String>> deleteCategory(dynamic id);
  Future<Either<String, String>> updateCategory(
    CategoryWrapper categoryWrapper,
  );
}
