import 'package:flutter/foundation.dart';
import 'package:todo/features/image/image.dart';
import 'dart:math';

final class ImageFakeDatasource extends ImageDatasource {
  ImageFakeDatasource._();

  late final List<({Image img, dynamic id})> _data;

  static Future<ImageFakeDatasource> init([int? seed]) async {
    final output = ImageFakeDatasource._();
    await output._init();
    return output;
  }

  Future<void> _init() async {
    _data = [];
  }

  bool _containsId(dynamic id) => _data.any((e) => e.id == id);

  @override
  Future addImage(Image image) {
    final maxId = _data.map((e) => e.id as int).reduce(max);
    _data.add((img: image, id: maxId + 1));
    return SynchronousFuture(maxId);
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
