import 'dart:io';

import 'package:benchmarking/benchmarking.dart';
import 'package:test/test.dart';

void main() {
  group('sync', () {
    test('class', () {
      final bench = TestBenchmarkSync();
      final result = bench.measure(BenchmarkTester.settings);
      BenchmarkTester.verify(bench, result);
    });

    test('functional', () {
      final bench = TestBenchmarkSync();
      final result = syncBenchmark('test', bench.run,
          setup: bench.setup,
          teardown: bench.teardown,
          settings: BenchmarkTester.settings);
      BenchmarkTester.verify(bench, result);
    });
  });

  group('async', () {
    test('class', () async {
      final bench = TestBenchmarkAsync();
      final result = await bench.measure(BenchmarkTester.settings);
      BenchmarkTester.verify(bench, result);
    });

    test('functional', () async {
      final bench = TestBenchmarkAsync();
      final result = await asyncBenchmark('test', bench.run,
          setup: bench.setup,
          teardown: bench.teardown,
          settings: BenchmarkTester.settings);
      BenchmarkTester.verify(bench, result);
    });
  });
}

class TestBenchmarkSync extends SyncBenchmark with BenchmarkTester {
  TestBenchmarkSync() : super('test');

  @override
  void setup() async => _setup();

  @override
  void teardown() async => _teardown();

  @override
  void run() => _run();
}

class TestBenchmarkAsync extends AsyncBenchmark with BenchmarkTester {
  TestBenchmarkAsync() : super('test');

  @override
  Future<void> setup() async => _setup();

  @override
  Future<void> teardown() async => _teardown();

  @override
  Future<void> run() async => _run();
}

mixin BenchmarkTester {
  int phase = 0;

  void _setup() {
    expect(phase, 0);
    phase++;
  }

  void _run() {
    expect(phase, greaterThanOrEqualTo(1));
    expect(phase, lessThanOrEqualTo(11)); // 1 run for warmup, 10 normal ones.
    phase++;
    sleep(Duration(milliseconds: 10));
  }

  void _teardown() {
    expect(phase, 12);
  }

  static const BenchmarkSettings settings = BenchmarkSettings(
      warmupTime: Duration(milliseconds: 10),
      minimumRunTime: Duration(milliseconds: 100));

  static void verify(dynamic bench, BenchmarkResult result) {
    expect(result.runs, 10);
    expect(result.totalRunTime.inMilliseconds, greaterThan(100));
    expect(result.totalRunTime.inMilliseconds, lessThan(120));
    expect(result.averageRunTime.inMicroseconds, greaterThan(10 * 1000));
    expect(result.averageRunTime.inMicroseconds, lessThan(11 * 1000));
    expect(result.runsPerSecond, greaterThan(90));
    expect(result.runsPerSecond, lessThan(100));
    bench.report(result);
  }
}
