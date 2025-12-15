import 'package:todo/features/category/category.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/image/image.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  CategoryRepository,
  CustomColorRepository,
  CategoryDatasource,
  ImageRepository,
])
void main() {}
