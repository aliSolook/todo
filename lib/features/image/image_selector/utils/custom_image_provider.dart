import 'dart:ui' as ui;
import 'package:dart_either/dart_either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo/features/image/image.dart';

class CustomImageProvider extends ImageProvider<CustomImageProvider> {
  CustomImageProvider({
    required this.imageId,
    required this.repository,
    this.scale = 1.0,
  });

  final dynamic imageId;
  final ImageRepository repository;

  final double scale;

  @override
  Future<CustomImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CustomImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CustomImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode: decode),
      scale: key.scale,
      debugLabel: 'CustomImageProvider(${key.imageId})',
    );
  }

  Future<ui.Codec> _loadAsync(
    CustomImageProvider key, {
    required ImageDecoderCallback decode,
  }) async {
    assert(key == this);
    final bytes = (await repository.getImage(imageId)).getOrThrow().data;

    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CustomImageProvider &&
        other.imageId == imageId &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(imageId, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'FileImage')}("$imageId", scale: ${scale.toStringAsFixed(1)})';
}
