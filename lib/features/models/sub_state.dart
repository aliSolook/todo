import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';

enum StateStatus { inProgress, failure, success }

class SubState<T> extends Equatable {
  final StateStatus? status;
  final Either<Null, T> _value;
  final String? _error;

  const SubState({
    Either<Null, T> value = const Left(null),
    this.status,
    String? error,
  }) : _value = value,
       _error = error;

  SubState.success(T value)
    : _value = Right(value),
      _error = null,
      status = StateStatus.success;

  const SubState.failure(this._error, [this._value = const Left(null)])
    : status = StateStatus.failure;

  const SubState.inProgress([this._value = const Left(null)])
    : _error = null,
      status = StateStatus.inProgress;

  const SubState.init()
    : _value = const Left(null),
      _error = null,
      status = null;

  T get value => _value.getOrElse(() => throw StateError('Value is not set'));

  Either<Null, T> get either => _value;

  String get error {
    assert(_error != null);
    return _error!;
  }

  String? get errorOrNull => _error;

  bool get isSuccess => status == StateStatus.success;
  bool get isFailure => status == StateStatus.failure;
  bool get isInProgress => status == StateStatus.inProgress;
  bool get isInit => status == null;

  @override
  List<Object?> get props => [status, _value, _error];
}
