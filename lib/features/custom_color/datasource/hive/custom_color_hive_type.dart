import 'package:hive/hive.dart';
import 'package:todo/features/custom_color/custom_color.dart';

part 'custom_color_hive_type.g.dart';

@HiveType(typeId: 4)
class CustomColorHiveType {
  @HiveField(0)
  final int color;

  const CustomColorHiveType(this.color);

  CustomColorWrapper wrap(int id) => CustomColorWrapper(id, color);
}
