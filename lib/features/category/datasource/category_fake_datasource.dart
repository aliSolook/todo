import 'dart:math';
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/category/category.dart';
import 'package:todo/features/image/image.dart';
import 'package:todo/utils/image_base_color_finder.dart';

class CategoryFakeDatasource implements CategoryDatasource {
  CategoryFakeDatasource(List<CategoryWrapper> data) : _data = data;

  final List<CategoryWrapper> _data;

  static Future<CategoryFakeDatasource> init([int? count, int? seed]) async {
    return CategoryFakeDatasource(await _init(count, Random(seed)));
  }

  static Future<List<CategoryWrapper>> _init(int? count, Random random) async {
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

    int randomColor() =>
        Colors.primaries[random.nextInt(Colors.primaries.length)].toARGB32();

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
          final color = image == null
              ? randomColor()
              : await ImageBaseColorFinder(imgRepo!).getColor(image);

          return CategoryWrapper(
            id: i,
            title: texts[random.nextInt(texts.length)],
            image: image,
            color: color,
          );
        },
      ),
    );
  }

  @override
  Future addCategory(Category category) async {
    int max = 0;
    for (var category in _data) {
      if (category.id as int > max) max = category.id;
    }

    _data.add(CategoryWrapper.fromCategory(++max, category));
    return SynchronousFuture(max);
  }

  @override
  Future<Iterable> addAllCategories(Iterable<Category> categories) {
    int max = 0;
    for (var category in _data) {
      if (category.id as int > max) max = category.id;
    }

    final output = <int>[];
    for (var category in categories) {
      _data.add(CategoryWrapper.fromCategory(++max, category));
      output.add(max);
    }

    return SynchronousFuture(output);
  }

  @override
  Future<void> deleteCategory(dynamic id) async {
    bool idExists = false;

    for (var i = 0; i < _data.length; i++) {
      if (_data[i].id == id) {
        _data.removeAt(i);
        idExists = true;
        break;
      }
    }

    if (!idExists) {
      throw CategoryNotFoundException(id);
    }
  }

  @override
  Future<CategoryWrapper> getCategory(dynamic id) async {
    final category = _data.cast<CategoryWrapper?>().firstWhere(
      (category) => category?.id == id,
      orElse: () => null,
    );

    if (category == null) {
      throw CategoryNotFoundException(id);
    }

    return category;
  }

  @override
  Future<List<CategoryWrapper>> listCategories() async {
    return List.from(_data);
  }

  @override
  Future<void> updateCategory(CategoryWrapper categoryWrapper) async {
    final index = _data.indexWhere(
      (category) => category.id == categoryWrapper.id,
    );
    if (index == -1) {
      throw CategoryNotFoundException(categoryWrapper);
    }
    _data[index] = categoryWrapper;
  }
}
