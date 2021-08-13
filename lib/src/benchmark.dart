import 'dart:async';

import 'package:meta/meta.dart';

import 'printer.dart';

/// Base class for benchmarks sync and async benchmarks
abstract class Benchmark {
  final String _name;
  final _output = Printer();

  Benchmark(this._name);

  void _report(BenchmarkResult result) {
    final msFractional = (Duration d) => Printer.format(
        d.inMicroseconds / Duration.microsecondsPerMillisecond,
        suffix: ' ms');
    _output
      ..blank()
      ..colored(Color.blue, _name)
      ..plain('   total runs: ${Printer.format(result.runs)}')
      ..colored(
          (result.totalRunTime.inMilliseconds >
                  result.settings.minimumRunTime.inMilliseconds * 1.25)
              ? Color.yellow
              : Color.none,
          '   total time: ${msFractional(result.totalRunTime)}')
      ..plain('  average run: ${msFractional(result.averageRunTime)}')
      ..plain('  runs/second: ${Printer.format(result.runsPerSecond)}');
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
  final int runs;
  final Duration totalRunTime;
  final BenchmarkSettings settings;

  BenchmarkResult._(this.settings, this.runs, this.totalRunTime);

  Duration get averageRunTime =>
      Duration(microseconds: totalRunTime.inMicroseconds ~/ runs);

  double get runsPerSecond =>
      Duration.microsecondsPerSecond / averageRunTime.inMicroseconds;
}

/// Base class for a synchronous code.
abstract class SyncBenchmark extends Benchmark {
  SyncBenchmark(String name) : super(name);

  // Override this with the benchmark code.
  void run();

  /// Prepare the benchmark before execution. Not included in the measured time.
  void setup() {}

  /// Clean up after the benchmark has finished.
  void teardown() => {};

  @nonVirtual
  void report([BenchmarkResult? result]) => _report(result ?? measure());

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
  static BenchmarkResult _measureUntil(
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
    return BenchmarkResult._(settings, runs, Duration(microseconds: totalUs));
  }
}

/// Base class for asynchronous code.
abstract class AsyncBenchmark extends Benchmark {
  AsyncBenchmark(String name) : super(name);

  // Override this with the benchmark code.
  Future<void> run();

  /// Prepare the benchmark before execution. Not included in the measured time.
  Future<void> setup() async {}

  /// Clean up after the benchmark has finished.
  Future<void> teardown() async => {};

  @nonVirtual
  Future<void> report([BenchmarkResult? result]) async =>
      _report(result ?? await measure());

  // Measures the [run()] function performance.
  @nonVirtual
  Future<BenchmarkResult> measure([BenchmarkSettings? settings]) async {
    settings ??= BenchmarkSettings();
    await setup();
    // Warmup for at least 100ms. Discard result.
    await _measureUntil(settings, run, settings.warmupTime.inMicroseconds);
    // Run the benchmark for at least 2000ms.
    final result = await _measureUntil(
        settings, run, settings.minimumRunTime.inMicroseconds);
    await teardown();
    return result;
  }

  /// Runs [fn] for at least [minimumMicroseconds].
  static Future<BenchmarkResult> _measureUntil(BenchmarkSettings settings,
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
    return BenchmarkResult._(settings, runs, Duration(microseconds: totalUs));
  }
}
