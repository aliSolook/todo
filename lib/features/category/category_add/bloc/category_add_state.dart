part of 'category_add_bloc.dart';

final class CategoryAddScreenState extends Equatable {
  final dynamic id;
  final String title;
  final dynamic image;
  final SubState<List<CustomColorWrapper>> customColorsState;
  final List<ListableDeleteState<dynamic>> customColorDeleteState;

  /// less than 0 means not set
  final int color;

  final String titleError;

  final SubState<CategoryWrapper> submitState;

  const CategoryAddScreenState({
    required this.id,
    required this.title,
    required this.image,
    required this.titleError,
    required this.submitState,
    required this.color,
    required this.customColorsState,
    required this.customColorDeleteState,
  });

  const CategoryAddScreenState.init({
    this.id,
    this.title = '',
    this.image,
    this.titleError = '',
    this.submitState = const SubState.init(),
    this.color = -1,
    this.customColorsState = const SubState.init(),
    this.customColorDeleteState = const [],
  });

  CategoryAddScreenState.fromCategory(
    CategoryWrapper category, {
    this.titleError = '',
    this.customColorsState = const SubState.init(),
    this.submitState = const SubState.init(),
    this.customColorDeleteState = const [],
  }) : id = category.id,
       title = category.title,
       image = category.image,
       color = category.color;

  CategoryAddScreenState copyWith({
    Either<Null, dynamic> id = const Left(null),
    String? title,
    Either<Null, dynamic> image = const Left(null),
    String? titleError,
    SubState<CategoryWrapper>? submitState,
    int? color,
    SubState<List<CustomColorWrapper>>? customColorsState,
    List<ListableDeleteState<dynamic>>? customColorDeleteState,
  }) => CategoryAddScreenState(
    id: id.getOrElse(() => this.id),
    title: title ?? this.title,
    image: image.getOrElse(() => this.image),
    titleError: titleError ?? this.titleError,
    submitState: submitState ?? this.submitState,
    color: color ?? this.color,
    customColorsState: customColorsState ?? this.customColorsState,
    customColorDeleteState:
        customColorDeleteState ?? this.customColorDeleteState,
  );

  bool get isEditing => id != null;

  bool get isReadyForSubmition => title.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    title,
    image,
    titleError,
    submitState,
    color,
    customColorsState,
    customColorDeleteState,
  ];
}
