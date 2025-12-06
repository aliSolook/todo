// import 'dart:async';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// void main(List<String> args) {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BlocProvider(
//         create: (context) => CounterBloc(),
//         child: const HomeScreen(),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.read<CounterBloc>().add(const CounterIncreamented());
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Center(
//         child: BlocBuilder<CounterBloc, CounterState>(
//           builder: (context, state) => Text('${state.count}'),
//         ),
//       ),
//     );
//   }
// }

// final class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc([super.initialState = const CounterState(0)]) {
//     on<CounterIncreamented>(onChanged);
//   }

//   FutureOr<void> onChanged(
//     CounterIncreamented event,
//     Emitter<CounterState> emit,
//   ) async {
//     // await emit.forEach(
//     //   stream,
//     //   onData: (data) {
//     //     print('onData');
//     //     return data.copyWith(count: state.count + 1);
//     //   },
//     // );
//     // onChanged2(event, emit);
//     onChanged2(event, emit);
//   }

//   FutureOr<void> onChanged2(
//     CounterIncreamented event,
//     Emitter<CounterState> emit,
//   ) {
//     emit(state.copyWith(count: state.count + 1));
//   }
// }

// final class CounterState extends Equatable {
//   final int count;

//   const CounterState(this.count);

//   CounterState copyWith({int? count}) => CounterState(count ?? this.count);

//   @override
//   List<Object?> get props => [count];
// }

// sealed class CounterEvent {
//   const CounterEvent();
// }

// final class CounterChanged extends CounterEvent {
//   final int newCounter;

//   const CounterChanged(this.newCounter);
// }

// final class CounterIncreamented extends CounterEvent {
//   const CounterIncreamented();
// }

// import 'package:flutter/cupertino.dart';

// void main(List<String> args) {
//   Child().testFn();
// }

// abstract class Base {
//   @mustCallSuper
//   void testFn({int? a}) {
//     print('from base');
//   }
// }

// mixin Mixin1 on Base {
//   @override
//   void testFn({int? a, int? b}) {
//     print('from interface');
//     super.testFn(a: a);
//   }
// }

// mixin Mixin2 on Base {
//   @override
//   void testFn({int? a, int? c}) {
//     print('from interface');
//     super.testFn(a: a);
//   }
// }

// abstract class ChildBase extends Base implements Mixin1, Mixin2 {
//   void testFn({int? a, int? b, int? c});
// }

// class Child extends ChildBase with Mixin1, Mixin2 {
//   @override
//   void testFn() {
//     print('from child');
//     super.testFn();
//   }
// }

import 'dart:async';
import 'dart:isolate';

void main() async {
  print(-1 % 3);
}

// FutureOr<void> fn() async {
//   final Interface instance = Implementation();
//   return instance();
// }

// abstract interface class Interface {
//   void call();
// }

// class Implementation implements Interface {
//   @override
//   FutureOr<void> call() async {
//     print('implementation begin');
//     await Future.delayed(const Duration(seconds: 2));
//     print('implementation end');
//   }
// }
