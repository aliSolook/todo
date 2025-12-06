// ignore_for_file: library_private_types_in_public_api

part of 'counter_add_screen_bloc.dart';

sealed class CounterAddScreenEvent {
  const CounterAddScreenEvent();
}

mixin _NoValueMixin {}

mixin _WithValueEventMixin<T> on CounterAddScreenEvent {
  T get value;
}

sealed class _WithValueEventImpl<T> extends CounterAddScreenEvent {
  final T value;

  const _WithValueEventImpl(this.value);
}

final class CounterAddScreenTitleFocusChanged = _WithValueEventImpl<bool>
    with _WithValueEventMixin<bool>;

final class CounterAddScreenTitleChanged = _WithValueEventImpl<String>
    with _WithValueEventMixin<String>;

final class CounterAddScreenDescriptionChanged = _WithValueEventImpl<String>
    with _WithValueEventMixin<String>;

final class CounterAddScreenImageChanged = _WithValueEventImpl<dynamic>
    with _WithValueEventMixin<dynamic>;

final class CounterAddScreenDurationFocusChanged = _WithValueEventImpl<bool>
    with _WithValueEventMixin<bool>;

final class CounterAddScreenDurationChanged = _WithValueEventImpl<Duration>
    with _WithValueEventMixin<Duration>;

final class CounterAddScreenSubmitted = CounterAddScreenEvent
    with _NoValueMixin;

final class CounterAddScreenResetRequested = CounterAddScreenEvent
    with _NoValueMixin;
