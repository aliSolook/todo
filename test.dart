// // import 'package:bloc/bloc.dart';

// // abstract class MyBlocEvents{}

// // final class IncrementEvent extends MyBlocEvents{}

// // final class DecrementEvent extends MyBlocEvents{}

// // class MyBloc extends Bloc<MyBlocEvents, int>{
// //   MyBloc(super.initialState){
// //     print('init state');
// //     on<IncrementEvent>((event, emit) => emit(state + 1));
// //     on<DecrementEvent>((event, emit) => emit(state - 1));
// //   }
// // }

// // void main(){

// // }
// typedef EventMatcher<E> = bool Function(E event);

// void main(List<String> args) {
//   final list = <_WhenHandler<Base, int>>[];
//   addToList(
//     list,
//     _WhenHandler<Child, int>(
//       4,
//       int,
//       (Child event) => false,
//     ),
//   );

//   final newList = list.whereType<_WhenHandler<Child, int>>().toList();
//   newList.first;
// }

// void addToList<T extends Base>(
//   List<_WhenHandler<Base, int>> list,
//   _WhenHandler<Base, int> element,
// ) => list.add(element);

// class _WhenHandler<Event, State> {
//   final State state;
//   final Type type;
//   final EventMatcher<Event> matcher;

//   _WhenHandler(this.state, this.type, this.matcher);
// }

// class Base {}

// class Child extends Base {}

void main(List<String> args) {
}