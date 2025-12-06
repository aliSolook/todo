import 'package:equatable/equatable.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class Task extends Equatable {
  final String title;
  final String description;
  final Duration duration;
  final Jalali startingDate;
  final dynamic category;
  final dynamic image;
  final bool status;

  const Task({
    required this.title,
    required this.description,
    required this.duration,
    required this.startingDate,
    required this.category,
    required this.image,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      startingDate: map['startingDate'],
      category: map['category'],
      image: map['image'],
      status: map['status'],
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    duration,
    startingDate,
    category,
    image,
    status,
  ];
}
