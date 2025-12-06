import 'package:equatable/equatable.dart';

class OrderItem<T> extends Equatable {
  final T value;
  final bool _isAsc;

  bool get isNotAsc => !_isAsc;
  bool get isNotDesc => _isAsc;

  bool get isAsc => _isAsc;
  bool get isDesc => !_isAsc;

  const OrderItem(this.value, [this._isAsc = true]);
  const OrderItem.asc(this.value) : _isAsc = true;
  const OrderItem.desc(this.value) : _isAsc = false;

  OrderItem<T> get toggled => isAsc ? toDesc : toAsc;
  OrderItem<T> get toAsc => OrderItem(value, true);
  OrderItem<T> get toDesc => OrderItem(value, false);

  @override
  List<Object?> get props => [_isAsc, value];
}
