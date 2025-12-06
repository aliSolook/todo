import 'dart:ui';
import 'package:equatable/equatable.dart';

class CustomColorWrapper extends Equatable {
  final dynamic id;
  final int color;

  const CustomColorWrapper(this.id, this.color);

  CustomColorWrapper copyWith({
    dynamic id,
    int? color,
  }) => CustomColorWrapper(id ?? this.id, color ?? this.color);

  @override
  List<Object?> get props => [id, color];

  Color toColor() => Color(color);
}
