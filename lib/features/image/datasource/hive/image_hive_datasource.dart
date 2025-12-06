import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:todo/features/image/image.dart';

final class ImageHiveDatasource extends ImageDatasource {
  final _box = Hive.box<ImageHiveType>('image_box');

  @override
  Future addImage(Image image) => _box.add(ImageHiveType.fromImage(image));

  @override
  Future<void> deleteImage(id) {
    if (!_box.containsKey(id)) {
      throw ImageNotFoundException(id);
    }
    return _box.delete(id);
  }

  @override
  Future<Image> getImage(id) {
    final output = _box.get(id);
    if (output == null) {
      throw ImageNotFoundException(id);
    }
    return SynchronousFuture(output.toImage());
  }

  @override
  Future<String> getTitle(id) => getImage(id).then((e) => e.title);

  @override
  Future<List<ImageWrapper>> listImages() => SynchronousFuture(
    _box.toMap().entries.map((e) => e.value.wrap(e.key)).toList(),
  );

  @override
  Future<void> updateImage(id, Image image) async {
    if (!_box.containsKey(id)) {
      throw ImageNotFoundException(id);
    }
    _box.put(id, ImageHiveType.fromImage(image));
  }
}
