import 'package:flutter/services.dart';
import 'package:todo/di/di.dart';
import 'package:todo/features/image/image.dart';

Future<ImageWrapper> addImageFromSource(Image source) async {
  final datasource = locator.get<ImageDatasource>();
  final id = await datasource.addImage(source);
  return ImageWrapper(id: id, title: source.title);
}

Future<ImageWrapper> addImage(String assetName) async =>
    addImageFromSource(await readImage(assetName));

Future<Image> readImage(String assetName) async {
  final title = assetName.split('/').last.split('.').first.replaceAll('_', ' ');
  final imageData = await rootBundle.load('assets/images/coding_image.png');
  return Image(data: imageData.buffer.asUint8List(), title: title);
}
