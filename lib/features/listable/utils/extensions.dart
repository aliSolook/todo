import 'package:todo/features/listable/listable.dart';


extension ListableStatusExtension on StateStatus? {
  bool get isInProgress => this == StateStatus.inProgress;
  bool get isFailure => this == StateStatus.failure;
  bool get isSuccess => this == StateStatus.success;
}

extension ListableListDeleteStateExtension<T> on List<ListableDeleteState<T>> {
  List<ListableDeleteState<T>> copyAdd(ListableDeleteState<T> item) =>
      followedBy([item]).toList();

  List<ListableDeleteState<T>> copyRemove(
    ListableDeleteState<T> item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return where((element) => !sameItem!(element.item, item.item)).toList();
  }

  List<ListableDeleteState<T>> copyUpdate(
    ListableDeleteState<T> item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    final newList = List.of(this);
    final index = indexWhere(
      (element) => sameItem!(element.item, item.item),
    );
    if (index < 0) throw StateError('Item to update not found in the list');
    newList[index] = item;

    return newList;
  }

  List<ListableDeleteState<T>> copyAddAll(
    Iterable<ListableDeleteState<T>> items,
  ) => followedBy(items).toList();

  List<ListableDeleteState<T>> copyRemoveAll(
    Iterable<ListableDeleteState<T>> items, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;

    return where(
      (element) => !items.any((e) => sameItem!(e.item, element.item)),
    ).toList();
  }

  List<ListableDeleteState<T>> copyUpdateAll(
    Iterable<ListableDeleteState<T>> items, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    final newList = List.of(this);
    final searchList = List.of(items);
    final indexes = <int, ListableDeleteState<T>>{};

    for (var i = 0; i < newList.length; i++) {
      for (var j = 0; j < searchList.length; j++) {
        if (sameItem(newList[i].item, searchList[j].item)) {
          indexes.addAll({j: searchList.removeAt(j)});
          break;
        }
      }
    }

    indexes.forEach((key, value) => newList[key] = value);
    newList.addAll(searchList);
    return newList;
  }

  bool hasResultFor(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return any(
      (element) => !element.isInProgress && sameItem!(item, element.item),
    );
  }

  bool isInProgress(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return any(
      (element) => element.isInProgress && sameItem!(item, element.item),
    );
  }

  bool isSuccess(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return any(
      (element) => element.isSuccess && sameItem!(item, element.item),
    );
  }

  bool isFailure(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return any(
      (element) => element.isFailure && sameItem!(item, element.item),
    );
  }

  bool checkStatus(
    T item,
    StateStatus status, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return any(
      (element) => element.status == status && sameItem!(item, element.item),
    );
  }

  StateStatus getStatus(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return firstWhere((element) => sameItem!(item, element.item)).status;
  }

  String? getMessage(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return firstWhere((element) => sameItem!(item, element.item)).message;
  }

  StateStatus? getStatusOrNull(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return (this as List<ListableDeleteState<T>?>)
        .firstWhere(
          (element) => sameItem!(item, element?.item),
          orElse: () => null,
        )
        ?.status;
  }

  String? getMessageOrNull(
    T item, [
    bool Function(T? a, T? b)? sameItem,
  ]) {
    sameItem ??= (a, b) => a == b;
    return (this as List<ListableDeleteState<T>?>)
        .firstWhere((element) => sameItem!(item, element?.item))
        ?.message;
  }
}

extension ListExtension<T> on List<T>{
  bool removeSingleWhere(bool Function(T e) test){
    final index = indexWhere(test);
    if(index < 0) return false;
    removeAt(index);
    return true;
  }
}