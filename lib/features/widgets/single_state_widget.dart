import 'package:flutter/material.dart';

typedef SetState = void Function(void Function() stateSetter);

class SingleStateWidget<T> extends StatefulWidget {
  const SingleStateWidget({
    super.key,
    required this.initState,
    required this.builder,
    this.onStateChanged,
    this.init,
    this.dispose,
    this.setState,
    this.child,
  });

  final void Function(void Function(T newState) setter, T state)? init;
  final void Function(T state)? dispose;
  final void Function(void Function(T newState) setter, T state)? setState;
  final bool Function(T previousState, T state)? onStateChanged;
  final Widget? child;
  final Widget Function(
    BuildContext context,
    SingleState<T> state,
    Widget? child,
  )
  builder;

  final T initState;

  @override
  State<SingleStateWidget> createState() => _SingleStateWidgetState<T>();
}

class _SingleStateWidgetState<T> extends State<SingleStateWidget<T>> {
  late final state = SingleState<T>(
    widget.initState,
    setState,
    widget.onStateChanged,
  );

  @override
  void initState() {
    if (widget.init != null) widget.init!((e) => state.value = e, state.value);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.dispose != null) widget.dispose!(state.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, state, widget.child);
  }
}

class SingleState<T> {
  T _value;

  final SetState setState;
  final bool Function(T oldState, T state)? _onStateChanged;

  SingleState(this._value, this.setState, this._onStateChanged);

  T get value => _value;
  set value(T newValue) {
    if (_onStateChanged != null && !_onStateChanged(value, newValue)) {
      return;
    }
    _value = newValue;
  }
}
