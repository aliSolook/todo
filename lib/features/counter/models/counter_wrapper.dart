import 'package:equatable/equatable.dart';
import 'package:todo/features/counter/models/counter.dart';

class CounterWrapper extends Equatable {
  final dynamic id;
  final String title;
  final String description;
  final Duration duration;
  final dynamic image;

  const CounterWrapper({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.duration,
  });

  CounterWrapper copyWith({
    dynamic id,
    String? title,
    String? description,
    Duration? duration,
    dynamic image,
  }) {
    return CounterWrapper(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      image: image ?? this.image,
    );
  }

  factory CounterWrapper.fromCounter(dynamic id, Counter counter) =>
      CounterWrapper(
        id: id,
        title: counter.title,
        description: counter.description,
        duration: counter.duration,
        image: counter.image,
      );

  Counter toCounter() => Counter(
    title: title,
    description: description,
    duration: duration,
    image: image,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    duration,
    image,
  ];
}
