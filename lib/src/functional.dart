import 'dart:async';

import 'package:benchmarking/src/benchmark.dart';

BenchmarkResult syncBenchmark(String name, void Function() fn,
    {void Function() setup = _empty,
    void Function() teardown = _empty,
    BenchmarkSettings? settings}) {
  final bench = _LambdaSyncBenchmark(name, fn, setup, teardown);
  return bench.measure(settings);
}

Future<BenchmarkResult> asyncBenchmark(String name, Future<void> Function() fn,
    {FutureOr<void> Function() setup = _emptyAsync,
    FutureOr<void> Function() teardown = _emptyAsync,
    BenchmarkSettings? settings}) async {
  final bench = _LambdaAsyncBenchmark(name, fn, setup, teardown);
  return await bench.measure(settings);
}

void _empty() {}
FutureOr<void> _emptyAsync() {}

class _LambdaSyncBenchmark extends SyncBenchmark {
  final void Function() _run;
  final void Function() _setup;
  final void Function() _teardown;

  _LambdaSyncBenchmark(String name, this._run, this._setup, this._teardown)
      : super(name);

  @override
  void run() => _run();

  @override
  void setup() => _setup();

  @override
  void teardown() => _teardown();
}

class _LambdaAsyncBenchmark extends AsyncBenchmark {
  final FutureOr<void> Function() _run;
  final FutureOr<void> Function() _setup;
  final FutureOr<void> Function() _teardown;

  _LambdaAsyncBenchmark(String name, this._run, this._setup, this._teardown)
      : super(name);

  @override
  Future<void> run() async => _run();

  @override
  Future<void> setup() async => _setup();

  @override
  Future<void> teardown() async => _teardown();
}
