import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/custom_color/custom_color.dart';
import 'package:todo/features/listable/listable.dart';

part 'custom_color_add_state.dart';

class CustomColorAddCubit extends Cubit<CustomColorAddState> {
  CustomColorAddCubit([CustomColorAddState? initialState])
    : super(initialState ?? CustomColorAddState.init());

  final _rep = locator.get<CustomColorRepository>();

  void colorChanged(HSVColor? newColor) =>
      emit(state.copyWith(color: newColor));

  void submit() async {
    emit(state.copyWith(submitState: const SubState.inProgress()));

    final either = await _rep.addCustomColor(state.color.toColor().toARGB32());

    final newState = either.fold(
      ifLeft: (error) => state.copyWith(submitState: SubState.failure(error)),
      ifRight: (id) => state.copyWith(
        submitState: SubState.success(
          CustomColorWrapper(id, state.color.toColor().toARGB32()),
        ),
      ),
    );

    emit(newState);
  }
}
