import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryAwairBlocBuilder<B extends StateStreamable<S>, S>
    extends StatefulWidget {
  const HistoryAwairBlocBuilder({
    super.key,
    this.bloc,
    this.buildWhen,
    required this.builder,
  });

  final B? bloc;

  final bool Function(S previous, S previouslyBuiltWith, S current)? buildWhen;

  final BlocWidgetBuilder<S> builder;

  Widget build(BuildContext context, S state) => builder(context, state);

  @override
  State<HistoryAwairBlocBuilder> createState() =>
      _HistoryAwairBlocBuilderState<B, S>();
}

class _HistoryAwairBlocBuilderState<B extends StateStreamable<S>, S>
    extends State<HistoryAwairBlocBuilder<B, S>> {
  late B _bloc;
  late S _state;
  late S _previouslyBuiltWithState;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = _bloc.state;
    _previouslyBuiltWithState = _state;
  }

  @override
  void didUpdateWidget(HistoryAwairBlocBuilder<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listenWhen: widget.buildWhen == null ? null : listenWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }

  bool listenWhen(S previous, S current) {
    final result = widget.buildWhen!(
      previous,
      _previouslyBuiltWithState,
      current,
    );

    if (result) _previouslyBuiltWithState = current;

    return result;
  }
}
