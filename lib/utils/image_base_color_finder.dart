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

      final colorsCount = <({num a, num r, num g, num b}), int>{};
      final iterator = image.iterator;

      while (iterator.moveNext()) {
        // rounding colors
        final current = (
          a: iterator.current.a ~/ 10,
          r: iterator.current.r ~/ 10,
          g: iterator.current.g ~/ 10,
          b: iterator.current.b ~/ 10,
        );

        colorsCount[current] = (colorsCount[current] ?? 0) + 1;
      }

      final entries = colorsCount.entries;
      MapEntry<({num a, num r, num g, num b}), int>? max;
      for (var element in entries) {
        if (element.key.a < 10) continue;
        if (element.value > (max?.value ?? -1)) max = element;
      }

      if (max == null) return fallbackColor!;

      final result = Color.fromARGB(
        (max.key.a * 10).clamp(0, 255).toInt(),
        (max.key.r * 10).clamp(0, 255).toInt(),
        (max.key.g * 10).clamp(0, 255).toInt(),
        (max.key.b * 10).clamp(0, 255).toInt(),
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
