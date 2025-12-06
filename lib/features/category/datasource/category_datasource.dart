import 'package:todo/features/category/models/category_wrapper.dart';
import 'package:todo/features/category/models/category.dart';

abstract class CategoryDatasource {
  Future<List<CategoryWrapper>> listCategories();
  Future<CategoryWrapper> getCategory(dynamic id);
  Future<dynamic> addCategory(Category category);
  Future<void> deleteCategory(dynamic id);
  Future<void> updateCategory(CategoryWrapper categoryWrapper);
}

class CategoryNotFoundException implements Exception {
  final dynamic id;

  CategoryNotFoundException(this.id);

  @override
  String toString() {
    return 'CategoryNotFoundException($id)';
  }
}
