import 'package:hive/hive.dart';
import 'package:todo/features/counter/counter.dart';

part 'counter_hive_type.g.dart';

@HiveType(typeId: 2)
class CounterHiveType {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int duration;

  @HiveField(3)
  final dynamic image;

  const CounterHiveType({
    required this.title,
    required this.description,
    required this.duration,
    required this.image,
  });

  factory CounterHiveType.fromCounter(Counter counter) => CounterHiveType(
    title: counter.title,
    description: counter.description,
    duration: counter.duration.inSeconds,
    image: counter.image,
  );

  CounterWrapper wrap(int id) => CounterWrapper(
    id: id,
    title: title,
    description: description,
    duration: Duration(seconds: duration),
    image: image,
  );
}
