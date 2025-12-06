import 'package:hive/hive.dart';
import 'package:todo/features/category/category.dart';

part 'category_hive_type.g.dart';

@HiveType(typeId: 1)
class CategoryHiveType {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final dynamic image;

  @HiveField(2)
  final int color;

  const CategoryHiveType({
    required this.title,
    required this.image,
    required this.color,
  });

  factory CategoryHiveType.fromCategory(Category category) => CategoryHiveType(
    title: category.title,
    image: category.image,
    color: category.color,
  );

  Category toCategory() => Category(title: title, image: image, color: color);

  CategoryWrapper wrap(int id) =>
      CategoryWrapper(id: id, title: title, image: image, color: color);
}
