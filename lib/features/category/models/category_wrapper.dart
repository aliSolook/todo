import 'package:equatable/equatable.dart';
import 'package:todo/features/category/category.dart';

class CategoryWrapper extends Equatable {
  final dynamic id;
  final String title;
  final dynamic image;
  final int color;

  const CategoryWrapper({
    required this.id,
    required this.title,
    required this.image,
    required this.color,
  });

  CategoryWrapper copyWith({
    dynamic id,
    String? title,
    dynamic image,
    int? color,
  }) {
    return CategoryWrapper(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      color: color ?? this.color,
    );
  }

  factory CategoryWrapper.fromCategory(dynamic id, Category category) =>
      CategoryWrapper(
        id: id,
        title: category.title,
        image: category.image,
        color: category.color,
      );

  Category toCategory() => Category(title: title, image: image, color: color);

  @override
  List<Object?> get props => [
    id,
    title,
    image,
    color,
  ];
}
