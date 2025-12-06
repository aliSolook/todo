part of 'custom_color_add_cubit.dart';

final class CustomColorAddState extends Equatable {
  final HSVColor color;
  final SubState<CustomColorWrapper> submitState;

  const CustomColorAddState({required this.color, required this.submitState});

  CustomColorAddState.init({
    HSVColor? color,
    this.submitState = const SubState.init(),
  }) : color = color ?? HSVColor.fromColor(const Color(0xFFFF0000));

  CustomColorAddState copyWith({
    HSVColor? color,
    SubState<CustomColorWrapper>? submitState,
  }) => CustomColorAddState(
    color: color ?? this.color,
    submitState: submitState ?? this.submitState,
  );

  @override
  List<Object?> get props => [color, submitState];
}
