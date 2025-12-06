// import 'package:todo/features/image/models/image_wrapper.dart';
// import 'package:todo/features/counter/counter.dart';
// import 'package:equatable/equatable.dart';

// class CounterWithImage extends Equatable {
//   final dynamic id;
//   final String title;
//   final String description;
//   final Duration duration;
//   final ImageWrapper? image;

//   const CounterWithImage({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.duration,
//     required this.image,
//   });

//   factory CounterWithImage.fromCounter(
//     CounterWrapper counter,
//     ImageWrapper? image,
//   ) => CounterWithImage(
//     id: counter.id,
//     title: counter.title,
//     description: counter.description,
//     duration: counter.duration,
//     image: image,
//   );

//   CounterWrapper toCounter() => CounterWrapper(
//     id: id,
//     title: title,
//     description: description,
//     image: image?.id,
//     duration: duration,
//   );

//   @override
//   List<Object?> get props => [id, title, description, duration, image];
// }
