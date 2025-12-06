import 'dart:math';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/features/task/task.dart';

class TaskFakeDatasource extends TaskDatasource {
  TaskFakeDatasource._(this._random);

  late final List<TaskWrapper> _data;
  final Random _random;

  static Future<TaskFakeDatasource> init([int? count, int? seed]) async {
    final output = TaskFakeDatasource._(Random(seed));
    await output._init(count);
    return output;
  }

  Future<void> _init(int? count) async {
    if (count == 0) {
      _data = [];
      return;
    }
    var max = (Jalali.now() - 10).millisecondsSinceEpoch;
    final categories = await () async {
      CategoryRepository? repo = locator.maybeGet();
      while (repo == null) {
        await Future.delayed(Duration.zero);
        repo = locator.maybeGet();
      }

      List<CategoryWrapper>? categories;

      while (categories == null) {
        await Future.delayed(Duration.zero);
        categories = (await repo.listCategories())
            .map<List<CategoryWrapper>?>((value) => value)
            .getOrThrow();
      }

      return categories;
    }();
    final images = await () async {
      ImageRepository? repo = locator.maybeGet();
      while (repo == null) {
        await Future.delayed(Duration.zero);
        repo = locator.maybeGet();
      }

      List<ImageWrapper>? images;

      while (images == null) {
        await Future.delayed(Duration.zero);
        images = (await repo.listImages())
            .map<List<ImageWrapper>?>((value) => value)
            .getOrThrow();
      }

      return images;
    }();

    final texts =
        'لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ، و با استفاده از طراحان گرافیک است، چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است، و برای شرایط فعلی تکنولوژی مورد نیاز، و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد، کتابهای زیادی در شصت و سه درصد گذشته حال و آینده، شناخت فراوان جامعه و متخصصان را می طلبد، تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی، و فرهنگ پیشرو در زبان فارسی ایجاد کرد، در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها، و شرایط سخت تایپ به پایان رسد و زمان مورد نیاز شامل حروفچینی دستاوردهای اصلی، و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.'
            .split(' ');

    final maxDelta = const Duration(hours: 4).inMilliseconds;
    final minDelta = const Duration(hours: 1).inMilliseconds;

    TaskWrapper taskGenerator(int i) {
      final duration = _random.nextInt(maxDelta - minDelta) + minDelta;
      max += duration;

      return TaskWrapper(
        id: i,
        title: List.generate(
          _random.nextInt(4) + 1,
          (_) => texts[_random.nextInt(texts.length)],
        ).join(' '),
        description: List.generate(
          _random.nextInt(10) + 1,
          (_) => texts[_random.nextInt(texts.length)],
        ).join(' '),
        duration: Duration(milliseconds: duration),
        startingDate: Jalali.fromMillisecondsSinceEpoch(max),
        category: categories[_random.nextInt(categories.length)].id,
        image: images.isEmpty
            ? null
            : images[_random.nextInt(images.length)].id,
        status: _random.nextInt(3) == 0,
      );
    }

    bool test(_) => _random.nextInt(3) > 0; // remove 1/3

    _data = Iterable.generate(count ?? _random.nextInt(365), taskGenerator).where(test).toList();
  }

  @override
  Future addTask(Task task) {
    int max = 0;
    for (var task in _data) {
      if (task.id as int > max) max = task.id;
    }

    _data.add(TaskWrapper.fromTask(++max, task));
    return SynchronousFuture(max);
  }

  @override
  Future<void> deleteTask(id) =>
      SynchronousFuture(_data.removeWhere((e) => e.id == id));

  @override
  Future<TaskWrapper> getTask(id) {
    final index = _data.indexWhere((e) => e.id == id);
    if (index < 0) throw TaskNotFoundException(id);
    return SynchronousFuture(_data[index]);
  }

  @override
  Future<List<TaskWrapper>> listTasks() => SynchronousFuture(List.of(_data));

  @override
  Future<void> updateTask(TaskWrapper taskWrapper) {
    final index = _data.indexWhere((e) => e.id == taskWrapper.id);
    if (index < 0) throw TaskNotFoundException(taskWrapper.id);

    _data[index] = taskWrapper;

    return SynchronousFuture(null);
  }

  @override
  Future<List<bool>> anyTasksInRanges(
    List<List<JalaliRange>> ranges, [
    bool? status,
  ]) {
    final List<bool> output = List.filled(ranges.length, false);
    final data = _data.where(
      (element) => status == null || element.status == status,
    );

    int foundCount = 0;

    for (var task in data) {
      if (foundCount == ranges.length) break;

      for (var i = 0; i < ranges.length; i++) {
        if (output[i]) continue;

        final result = ranges[i].any(
          (range) =>
              range.inRange(task.startingDate) || range.inRange(task.endDate),
        );

        if (result) {
          output[i] = result;
          foundCount++;
        }
      }
    }

    return SynchronousFuture(output);
  }

  @override
  Future<List<TaskWrapper>> listTasksInRange(
    List<JalaliRange> ranges, [
    bool? status,
  ]) => SynchronousFuture(
    _data
        .where(
          (task) =>
              (status == null || status == task.status) &&
              ranges.any(
                (range) =>
                    range.inRange(task.startingDate) ||
                    range.inRange(task.endDate),
              ),
        )
        .toList(),
  );
}

String format(Jalali date) => '${date.formatter.d} ${date.formatter.mN}';
