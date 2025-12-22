import 'dart:math';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/counter/datasource/counter_datasource.dart';
import 'package:todo/features/counter/models/counter_wrapper.dart';
import 'package:todo/features/counter/models/counter.dart';
import 'package:todo/features/image/image.dart';

class CounterFakeDatasource implements CounterDatasource {
  final List<CounterWrapper> _data;

  const CounterFakeDatasource(this._data);

  static Future<CounterFakeDatasource> init({int? count, int? seed}) async {
    return CounterFakeDatasource(await _init(count, Random(seed)));
  }

  static Future<List<CounterWrapper>> _init(int? count, Random random) async {
    if (count == 0) return [];

    ImageRepository? imgRepo = locator.maybeGet();
    while (imgRepo == null) {
      await Future.delayed(Duration.zero);
      imgRepo = locator.maybeGet();
    }

    final images = await () async {
      List<ImageWrapper>? images;

      while (images == null) {
        await Future.delayed(Duration.zero);
        images = (await imgRepo!.listImages())
            .map<List<ImageWrapper>?>((value) => value)
            .getOrThrow();
      }

      return images;
    }();

    final texts =
        'لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ، و با استفاده از طراحان گرافیک است، چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است، و برای شرایط فعلی تکنولوژی مورد نیاز، و کاربردهای متنوع با هدف بهبود ابزارهای کاربردی می باشد، کتابهای زیادی در شصت و سه درصد گذشته حال و آینده، شناخت فراوان جامعه و متخصصان را می طلبد، تا با نرم افزارها شناخت بیشتری را برای طراحان رایانه ای علی الخصوص طراحان خلاقی، و فرهنگ پیشرو در زبان فارسی ایجاد کرد، در این صورت می توان امید داشت که تمام و دشواری موجود در ارائه راهکارها، و شرایط سخت تایپ به پایان رسد و زمان مورد نیاز شامل حروفچینی دستاوردهای اصلی، و جوابگوی سوالات پیوسته اهل دنیای موجود طراحی اساسا مورد استفاده قرار گیرد.'
            .split(' ');

    return await Future.wait(
      Iterable.generate(
        count ?? random.nextInt(7) + 3,
        (i) async {
          final image = images.isEmpty
              ? null
              : images[random.nextInt(images.length)].id;

          return CounterWrapper(
            id: i,
            title: texts[random.nextInt(texts.length)],
            image: image,
            description: List.generate(
              random.nextInt(8) + 2,
              (_) => texts[random.nextInt(texts.length)],
            ).join(' '),
            duration: Duration(
              minutes: random.nextInt(10),
              seconds: random.nextInt(60),
            ),
          );
        },
      ),
    );
  }

  @override
  Future<int> addCounter(Counter counter) async {
    int max = 0;

    for (var counter in _data) {
      if (max > counter.id) max = counter.id;
    }

    _data.add(CounterWrapper.fromCounter(++max, counter));
    return max;
  }

  @override
  Future<Iterable> addAllCounters(Iterable<Counter> counters) {
    int max = 0;
    for (var counter in _data) {
      if (counter.id > max) max = counter.id;
    }

    final output = <int>[];
    for (var counter in counters) {
      _data.add(CounterWrapper.fromCounter(++max, counter));
      output.add(max);
    }

    return SynchronousFuture(output);
  }

  @override
  Future<void> deleteCounter(dynamic id) async {
    final index = _data.indexWhere((e) => e.id == id);

    if (index < 0) {
      throw CounterNotFoundException(id);
    }

    _data.removeAt(index);
  }

  @override
  Future<CounterWrapper> getCounter(dynamic id) async {
    final counter = _data.cast<CounterWrapper?>().firstWhere(
      (counter) => counter?.id == id,
      orElse: () => null,
    );

    if (counter == null) {
      throw CounterNotFoundException(id);
    }

    return counter;
  }

  @override
  Future<List<CounterWrapper>> listCounters() =>
      SynchronousFuture(List.from(_data));

  @override
  Future<void> updateCounter(CounterWrapper counterWrapper) async {
    final index = _data.indexWhere((counter) => counter.id == counterWrapper);
    if (index < 0) {
      throw CounterNotFoundException(counterWrapper);
    }
    _data[index] = counterWrapper;
  }
}
