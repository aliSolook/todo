import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:todo/features/image/datasource/image_datasource.dart';
import 'package:todo/features/image/models/image_wrapper.dart';
import 'package:todo/features/image/models/image.dart';
import 'package:uuid/uuid.dart';

class ImageLocalFileDatasource extends ImageDatasource {
  static const _extension = '.img';
  Directory? _applicationDocumentDirectory;

  Future<Directory> get _getBaseDirectory async {
    _applicationDocumentDirectory ??= await getApplicationDocumentsDirectory();

    return Directory(
      p.join(_applicationDocumentDirectory!.path, 'todo', 'images'),
    );
  }

  @override
  Future<dynamic> addImage(Image image) async {
    final name = createName(image.title);
    final filePath = await createPath(name);
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(image.data);
    return name;
  }

  @override
  Future<void> deleteImage(dynamic id) async {
    final file = File(id);
    if (!await file.exists()) {
      throw ImageNotFoundException(id);
    }

    await file.delete();
  }

  @override
  Future<Image> getImage(id) async {
    final file = File(await createPath(id.toString()));
    if (!await file.exists()) {
      throw ImageNotFoundException(id);
    }

    final title = extractTitle(file.path);

    return Image(title: title, data: await file.readAsBytes());
  }

  @override
  Future<String> getTitle(id) => SynchronousFuture(extractTitle(id.toString()));

  @override
  Future<List<ImageWrapper>> listImages() async {
    bool filter(FileSystemEntity f) => f is File && f.path.endsWith('.img');

    // final transformer = MyTransformer<FileSystemEntity, ImageWrapper>(
    //   handleData: (file, addDoneListener) async {
    //     assert(file is File);
    //     file as File;

    //     final completer = Completer<Uint8List>();

    //     final buffer = BytesBuilder(copy: false);
    //     final subscription = file.openRead().listen(
    //       buffer.add,
    //       onDone: () {
    //         if (completer.isCompleted) return;
    //         completer.complete(buffer.toBytes());
    //       },
    //     );
    //     addDoneListener(() {
    //       if (completer.isCompleted) return;
    //       subscription.cancel();
    //       completer.complete(Uint8List(0));
    //     });

    //     return ImageWrapper(
    //       id: file.path,
    //       title: extractTitle(file.path),
    //       data: await completer.future,
    //     );
    //   },
    // );

    // Stream<ImageWrapper> expander(Directory e) =>
    //     e.list().where(filter).transform(transformer);

    // return _getBaseDirectory.asStream().asyncExpand(expander);

    ImageWrapper converter(FileSystemEntity file) => ImageWrapper(
      id: p.basenameWithoutExtension(file.path),
      title: extractTitle(file.path),
    );

    final directory = await _getBaseDirectory;
    if (!await directory.exists()) await directory.create(recursive: true);

    return directory.list().where(filter).map(converter).toList();
  }

  @override
  Future<void> updateImage(dynamic id, Image image) async {
    var file = File(id.toString());
    if (!await file.exists()) {
      throw ImageNotFoundException(id);
    }

    if (extractTitle(id.toString()) != image.title) {
      file = await file.rename(await createPath(image.title));
    }

    await file.writeAsBytes(image.data);
  }

  String extractTitle(String path) {
    final basename = p.basenameWithoutExtension(path);
    final splitterPosition = basename.indexOf('__');
    if (splitterPosition == -1) throw ImageNotFoundException(basename);
    return basename.substring(splitterPosition + 2);
  }

  String extractName(String path) => p.basenameWithoutExtension(path);

  Future<String> createPath(String name) async {
    final directory = await _getBaseDirectory;
    return p.joinAll([directory.path, '$name$_extension']);
  }

  String createName(String title) => '${const Uuid().v4()}__$title';
}

// TODO: remove this from here

// typedef Callback = void Function();
// typedef AddDoneCallback = void Function(Callback onDone);

// class MyTransformer<S, T> extends StreamTransformerBase<S, T> {
//   final Future<T> Function(
//     S event,
//     AddDoneCallback addOnDoneListener,
//   )?
//   handleData;
//   final Future<Object> Function(
//     Object? event,
//     AddDoneCallback addOnDoneListener,
//   )?
//   handleError;

//   MyTransformer({this.handleData, this.handleError});

//   @override
//   Stream<T> bind(Stream<S> stream) {
//     final controller = StreamController<T>();
//     final List<Future> waitList = [];
//     final List<Callback> listeners = [];
//     bool isDone = false;

//     void addListener(Callback listener) => listeners.add(listener);
//     void onDone(_) {
//       isDone = true;
//       controller.close();

//       for (var element in listeners) {
//         element();
//       }
//     }

//     controller.done.then(onDone);
//     stream.listen(
//       (event) {
//         if (handleData == null) return controller.add(event as T);

//         final result = handleData!(event, addListener).then((value) {
//           if (isDone) return;
//           controller.add(value);
//         });

//         waitList.add(result);
//       },
//       onDone: () async {
//         await Future.wait(waitList);

//         controller.close();
//       },
//       onError: (e) async {
//         if (handleError == null) return controller.addError(e);
//         final result = await handleError!(e, addListener);
//         if (isDone) return;
//         controller.addError(result);
//       },
//     );

//     return controller.stream;
//   }
// }
