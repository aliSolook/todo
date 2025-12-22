import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:todo/features/image/image.dart';
import 'dart:math';

final class ImageFakeDatasource extends ImageDatasource {
  ImageFakeDatasource(this._data);

  final List<({Image img, dynamic id})> _data;

  static Future<ImageFakeDatasource> init({int? count, int? seed}) async =>
      ImageFakeDatasource(await _init(count, Random(seed)));

  static Future<List<({Image img, dynamic id})>> _init(
    int? count,
    Random random,
  ) async {
    if (count == 0) return [];
    final assets = [
      'assets/images/coding_image.png',
      'assets/images/exercise.png',
      'assets/images/shopping.png',
      'assets/images/study.png',
      'assets/images/studying_image.png',
      'assets/images/teaching_image.png',
    ];

    Future<Image> readImage(String assetName) async {
      final data = await rootBundle.load(assetName);
      final title = assetName
          .split('\\')
          .last
          .split('/')
          .last
          .split('.')
          .first
          .replaceAll('_', ' ');
      return Image(title: title, data: data.buffer.asUint8List());
    }

    if (count == null) {
      return Future.wait(
        assets
            .map(readImage)
            .toList()
            .asMap()
            .entries
            .map((value) async => (img: await value.value, id: value.key)),
      );
    }

    Future<({Image img, dynamic id})> converter(dynamic id) async {
      final assetName = assets[random.nextInt(assets.length)];
      final img = await readImage(assetName);
      return (img: img, id: id);
    }

    return Future.wait(
      List.generate(count ?? random.nextInt(7) + 3, (i) => i).map(converter),
    );
  }

  bool _containsId(dynamic id) => _data.any((e) => e.id == id);

  @override
  Future addImage(Image image) {
    final maxId = _data.map((e) => e.id as int).fold(0, max);
    _data.add((img: image, id: maxId + 1));
    return SynchronousFuture(maxId + 1);
  }

  @override
  Future<void> deleteImage(id) async {
    if (!_containsId(id)) {
      throw ImageNotFoundException(id);
    }
    _data.removeWhere((e) => e.id == id);
  }

  @override
  Future<Image> getImage(id) {
    final index = _data.indexWhere((e) => e.id == id);
    if (index < -1) {
      throw ImageNotFoundException(id);
    }
    return SynchronousFuture(_data[index].img);
  }

  @override
  Future<String> getTitle(id) => getImage(id).then((e) => e.title);

  @override
  Future<List<ImageWrapper>> listImages() => SynchronousFuture(
    _data.map((e) => ImageWrapper(id: e.id, title: e.img.title)).toList(),
  );

  @override
  Future<void> updateImage(id, Image image) async {
    final index = _data.indexWhere((e) => e.id == id);
    if (index < -1) {
      throw ImageNotFoundException(id);
    }

    _data[index] = (id: id, img: image);
  }
}
