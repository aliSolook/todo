import 'package:hive/hive.dart';
import 'package:todo/features/category/category.dart';

class CategoryLocalDatasource implements CategoryDatasource {
  final _box = Hive.box<CategoryHiveType>('category_box');

  @override
  Future<dynamic> addCategory(Category category) {
    return _box.add(CategoryHiveType.fromCategory(category));
  }

  @override
  Future<Iterable> addAllCategories(Iterable<Category> categories) {
    return _box.addAll(categories.map(CategoryHiveType.fromCategory));
  }

  @override
  Future<void> deleteCategory(dynamic id) {
    if (!_box.containsKey(id)) {
      throw CategoryNotFoundException(id);
    }
    return _box.delete(id);
  }

  @override
  Future<CategoryWrapper> getCategory(dynamic id) async {
    final output = _box.get(id);
    if (output == null) {
      throw CategoryNotFoundException(id);
    }
    return output.wrap(id);
  }

  @override
  Future<List<CategoryWrapper>> listCategories() async {
    return _box.toMap().entries.map((e) => e.value.wrap(e.key)).toList();
  }

  @override
  Future<void> updateCategory(CategoryWrapper categoryWrapper) async {
    if (!_box.containsKey(categoryWrapper.id)) {
      throw CategoryNotFoundException(categoryWrapper.id);
    }
    _box.put(
      categoryWrapper.id,
      CategoryHiveType.fromCategory(categoryWrapper.toCategory()),
    );
  }
}
