import 'dart:async';

import 'package:meta/meta.dart';

import 'printer.dart';

/// Base class for benchmarks sync and async benchmarks
abstract class Benchmark {
  late final String _name;

  Benchmark._(String? name) {
    _name = name ?? runtimeType.toString();
  }
}

class BenchmarkSettings {
  /// Time to run the function to warm it up in the VM. Not measured.
  final Duration warmupTime;

  /// Function will be executed multiple times until [minimumRunTime] passes.
  final Duration minimumRunTime;

  const BenchmarkSettings(
      {this.warmupTime = const Duration(milliseconds: 100),
      this.minimumRunTime = const Duration(seconds: 2)});
}

class BenchmarkResult {
  final Benchmark _benchmark;
  final int runs;
  final Duration totalRunTime;
  final BenchmarkSettings settings;

  BenchmarkResult._(
      this._benchmark, this.settings, this.runs, this.totalRunTime);

  Duration get averageRunTime =>
      Duration(microseconds: totalRunTime.inMicroseconds ~/ runs);

  double get runsPerSecond =>
      Duration.microsecondsPerSecond / averageRunTime.inMicroseconds;

  void report({int? units, Printer output = const Printer()}) {
    output
      ..blank()
      ..colored(Color.blue, _benchmark._name)
      ..labeled('total runs', runs)
      ..labeled(
          'total time', Printer.formatMicroseconds(totalRunTime.inMicroseconds),
          color: (totalRunTime.inMilliseconds >
                  settings.minimumRunTime.inMilliseconds * 1.25)
              ? Color.yellow
              : Color.none)
      ..labeled('average run',
          Printer.formatMicroseconds(averageRunTime.inMicroseconds))
      ..labeled('runs/second', runsPerSecond);
    if (units != null) {
      output
        ..labeled('units', units)
        ..labeled('units/second', unitsPerSecond(units))
        ..labeled('time per unit',
            Printer.formatMicroseconds(microsecondsPerUnit(units)));
    }
  }

  double unitsPerSecond(int units) =>
      Duration.microsecondsPerSecond / microsecondsPerUnit(units);

  double microsecondsPerUnit(int units) =>
      averageRunTime.inMicroseconds / units;
}

/// Base class for a synchronous code.
abstract class SyncBenchmark extends Benchmark {
  SyncBenchmark([String? name]) : super._(name);

  // Override this with the benchmark code.
  void run();

  /// Prepare the benchmark before execution. Not included in the measured time.
  void setup() {}

  /// Clean up after the benchmark has finished.
  void teardown() {}

  // Measures the [run()] function performance.
  @nonVirtual
  BenchmarkResult measure([BenchmarkSettings? settings]) {
    settings ??= BenchmarkSettings();
    setup();
    // Warmup for at least 100ms. Discard result.
    _measureUntil(settings, run, settings.warmupTime.inMicroseconds);
    // Run the benchmark for at least 2000ms.
    final result =
        _measureUntil(settings, run, settings.minimumRunTime.inMicroseconds);
    teardown();
    return result;
  }

  /// Runs [fn] for at least [minimumMicroseconds].
  BenchmarkResult _measureUntil(
      BenchmarkSettings settings, Function() fn, int minimumMicroseconds) {
    var runs = 0;
    var totalUs = 0;
    final watch = Stopwatch();
    while (totalUs < minimumMicroseconds) {
      watch.start();
      fn();
      watch.stop();
      totalUs = watch.elapsedMicroseconds;
      runs++;
    }
    return BenchmarkResult._(
        this, settings, runs, Duration(microseconds: totalUs));
  }
}

/// Base class for asynchronous code.
abstract class AsyncBenchmark extends Benchmark {
  AsyncBenchmark([String? name]) : super._(name);

  // Override this with the benchmark code.
  Future<void> run();

  /// Prepare the benchmark before execution. Not included in the measured time.
  Future<void> setup() async {}

  /// Clean up after the benchmark has finished.
  Future<void> teardown() async {}

  // Measures the [run()] function performance.
  @nonVirtual
  Future<BenchmarkResult> measure([BenchmarkSettings? settings]) async {
    settings ??= BenchmarkSettings();
    try {
      await setup();
      // Warmup for at least 100ms. Discard result.
      await _measureUntil(settings, run, settings.warmupTime.inMicroseconds);
      // Run the benchmark for at least 2000ms.
      final result = await _measureUntil(
          settings, run, settings.minimumRunTime.inMicroseconds);
      await teardown();
      return result;
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Runs [fn] for at least [minimumMicroseconds].
  Future<BenchmarkResult> _measureUntil(BenchmarkSettings settings,
      Future Function() fn, int minimumMicroseconds) async {
    var runs = 0;
    var totalUs = 0;
    final watch = Stopwatch();
    while (totalUs < minimumMicroseconds) {
      watch.start();
      await fn();
      watch.stop();
      totalUs = watch.elapsedMicroseconds;
      runs++;
    }
    return BenchmarkResult._(
        this, settings, runs, Duration(microseconds: totalUs));
  }
}
