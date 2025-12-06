import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String title;
  final dynamic image;
  final int color;

  const Category({
    required this.title,
    required this.image,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> map) {
    return Category(
      title: map['title'],
      image: map['image'],
      color: map['color'],
    );
  }

  @override
  List<Object?> get props => [title, image, color];
}
