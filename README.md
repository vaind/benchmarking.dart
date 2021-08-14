# Benchmarking

Provides tools to measure performance of your code. You can run simple micro-benchmarks while picking the best approach for the function you're just writing, or benchmark more complex code with greater control on setup and teardown.

There's first-class support for both synchronous as well as **`async`** code so that you get the most accurate measurements at all times.

You can also choose from two approaches to define your benchmarks - do it via a class-based interface, like with `package:benchmark_harness` or a functional one, like writing tests with `package:test`.

## Writing your own bechmarks

To write a benchmark, you just write a `run` function. If your code needs it, you can also provide `setup` and `teardown` functions to prepare the benchmark before executing and clean up afterwards, respectively.

In the following example, we compare element access performance for `HashMap` and the default `Map` implementation.
Note: if you actually run this benchmark, notice how changing the number of items influences the result.

```dart
void main () {
  final numbers = List.generate(10000, (i) => i);
  final map = {for (var n in numbers) n: n.toString()};
  final hashMap = HashMap<int, String>.fromEntries(map.entries);
  final randomizedKeys = numbers.toList()..shuffle();
  String? result; // so that the loop isn't optimized out

  // This is a "functional" benchmark definition.
  // Alternatively, you can define your benchmark as a class, by overriding either SyncBenchmark or AsyncBenchmark.
  syncBenchmark('Map[k]', () => randomizedKeys.forEach((key) => result = map[key]))
      .report(units: numbers.length); // report() takes an optional argument to report "per unit" performance
  syncBenchmark('HashMap[k]', () => randomizedKeys.forEach((key) => result = hashMap[key]))
      .report(units: numbers.length);
}
```

A result of running the benchmark would look something like:

```shell
$ dart run example/benchmarking.dart

Map[k]
          total runs:   8 801
          total time: 2 000.1 ms
         average run:  0.2270 ms
         runs/second: 4 405.3
               units:  10 000
        units/second: 4 405.3
       time per unit:  0.0227 μs

HashMap[k]
          total runs:  18 839
          total time: 2 000.0 ms
         average run:  0.1060 ms
         runs/second: 9 434.0
               units:  10 000
        units/second: 9 434.0
       time per unit:  0.0106 μs
```
