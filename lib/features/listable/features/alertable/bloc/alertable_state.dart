import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:todo/features/listable/listable.dart';

abstract class AlertableBaseState<T, A> extends ListableState<T> {
  @override
  AlertableBaseState<T, A> copyWith({
    List<T>? sourceItems,
    List<T>? manipulatedItems,
    Either<Null, StateStatus?> status = const Left(null),
    List<ListableDeleteState<T>>? deleteState,
    Either<Null, String?> error = const Left(null),
    Either<Null, Alert<A>?> alert = const Left(null),
  });
}

mixin AlertableState<T, A> on AlertableBaseState<T, A> {
  Alert<A>? get alert;

  @override
  List<Object?> get props => [...super.props, alert];
}

enum AlertType {
  alert,
  success,
  warning,
  error;

  bool get isAlert => this == AlertType.alert;
  bool get isSuccess => this == AlertType.success;
  bool get isWarning => this == AlertType.warning;
  bool get isError => this == AlertType.error;
}

class Alert<A> extends Equatable {
  final AlertType type;
  final A message;

  const Alert({required this.type, required this.message});

  const Alert.alert(this.message) : type = AlertType.alert;
  const Alert.success(this.message) : type = AlertType.success;
  const Alert.warning(this.message) : type = AlertType.warning;
  const Alert.error(this.message) : type = AlertType.error;

  bool get isAlert => type.isAlert;
  bool get isSuccess => type.isSuccess;
  bool get isWarning => type.isWarning;
  bool get isError => type.isError;

  @override
  List<Object?> get props => [type, message];
}
