import 'package:equatable/equatable.dart';

class Counter extends Equatable {
  final String title;
  final String description;
  final Duration duration;
  final dynamic image;

  const Counter({
    required this.title,
    required this.description,
    required this.duration,
    required this.image,
  });

  factory Counter.fromJson(Map<String, dynamic> map) {
    return Counter(
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      image: map['image'],
    );
  }

  Counter copyWith({
    String? title,
    String? description,
    Duration? duration,
    dynamic image,
  }) {
    return Counter(
      title: title ?? this.title,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    duration,
    image,
  ];
}
