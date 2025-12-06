// TrackableTickerProvider - A TickerProvider that tracks ticker creation
import 'package:flutter/scheduler.dart';

class TrackableTickerProvider extends TickerProvider {
  final Function(String) onTickerCreated;
  final Function(String) onTickerDisposed;
  final String providerName;

  // final Map<Ticker, String> _activeTickers = {};

  TrackableTickerProvider({
    required this.onTickerCreated,
    required this.onTickerDisposed,
    required this.providerName,
  });

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = _TrackableTicker(
      onTick,
      debugLabel: 'Ticker from $providerName',
      onTickerCreated: (ticker, name) {
        // _activeTickers[ticker] = name;
        onTickerCreated(name);
      },
      onTickerDisposed: (ticker, name) {
        // _activeTickers.remove(ticker);
        onTickerDisposed(name);
      },
    );

    return ticker;
  }
}

// Trackable Ticker implementation
class _TrackableTicker extends Ticker {
  final Function(Ticker, String) onTickerCreated;
  final Function(Ticker, String) onTickerDisposed;

  _TrackableTicker(
    super.onTick, {
    required super.debugLabel,
    required this.onTickerCreated,
    required this.onTickerDisposed,
  }) {
    onTickerCreated(this, super.debugLabel ?? 'null');
  }

  @override
  void dispose() {
    onTickerDisposed(this, super.debugLabel ?? 'null');
    super.dispose();
  }
}
