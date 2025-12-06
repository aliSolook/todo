import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SimulationDriver {
  Simulation? _simulation;
  late final Ticker _ticker;
  final void Function(double x) onTick;

  SimulationDriver({required this.onTick, required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_tick);
  }

  void start(Simulation simulation) {
    stop();
    _simulation = simulation;
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
    _simulation = null;
  }

  void dispose() {
    _ticker.dispose();
  }

  void _tick(Duration elapsed) {
    assert(_simulation != null);
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final x = _simulation!.x(seconds);
    if (_simulation!.isDone(seconds)) {
      stop();
    }
    onTick(x);
  }
}
