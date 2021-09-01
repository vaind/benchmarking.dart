# Benchmarking

This package provides tools to measure performance of your code. Some features:

* first-class support both **sync** and **async** code
* a class-based interface (like `package:benchmark_harness`)
* a functional interface (like `package:test`)
* handles simple micro-benchmarks as well as more complex ones (with setup and teardown functions)

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
          total runs:      8 527
          total time:     2.0001  s
         average run:        234 μs
         runs/second:    4 273.5
               units:     10 000
        units/second: 42 735 043
       time per unit:     0.0234 μs

HashMap[k]
          total runs:     17 347
          total time:     2.0000  s
         average run:        115 μs
         runs/second:    8 695.7
               units:     10 000
        units/second: 86 956 522
       time per unit:     0.0115 μs
```
