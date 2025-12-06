import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:todo/features/image/image.dart' as local_img;

class ImageBaseColorFinder {
  ImageBaseColorFinder(this.imageRepository);

  final local_img.ImageRepository imageRepository;
  final _cache = <dynamic, int>{};

  Future<int> getColor(dynamic imgId, [int? fallbackColor]) async {
    fallbackColor ??= Random().nextInt(0xFFFFFF) + 0xFF000000;

    if (_cache[imgId] != null) return _cache[imgId]!;
    final data = (await imageRepository.getImage(imgId)).orNull()?.data;
    if (data == null) return fallbackColor;

    int mostUsedColor() {
      final image = img.decodeImage(data);
      if (image == null) return fallbackColor!;

      final colorsCount = <img.Color, int>{};
      final iterator = image.iterator;

      while (iterator.moveNext()) {
        colorsCount[iterator.current] =
            (colorsCount[iterator.current] ?? 0) + 1;
      }

      final entries = colorsCount.entries;
      MapEntry<img.Color, int>? max;
      for (var element in entries) {
        if (element.value > (max?.value ?? -1)) max = element;
      }

      if (max == null) return fallbackColor!;
      final result = Color.from(
        alpha: max.key.aNormalized.toDouble(),
        red: max.key.rNormalized.toDouble(),
        green: max.key.gNormalized.toDouble(),
        blue: max.key.bNormalized.toDouble(),
      ).toARGB32();
      return _cache[imgId] = result;
    }

    int averageColor() {
      final image = img.decodeImage(data);
      if (image == null) return fallbackColor!;

      double a = 0;
      double r = 0;
      double g = 0;
      double b = 0;
      final iterator = image.iterator;

      while (iterator.moveNext()) {
        a += iterator.current.aNormalized.toDouble();
        r += iterator.current.rNormalized.toDouble();
        g += iterator.current.gNormalized.toDouble();
        b += iterator.current.bNormalized.toDouble();
      }

      return Color.from(
        alpha: a / image.length,
        red: r / image.length,
        green: g / image.length,
        blue: b / image.length,
      ).toARGB32();
    }

    return await Isolate.run(mostUsedColor);
  }
}
