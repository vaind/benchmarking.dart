import 'dart:collection';

import 'package:benchmarking/benchmarking.dart';

void main() async {
  lists();
  maps();
  await futureWaiting();
}

// Create a list of 1 million integers from 0 to 999999.
void lists() {
  final size = 1000 * 1000;
  syncBenchmark('List.generate()',
      () => List.generate(size, (i) => i, growable: true)).report();
  syncBenchmark('List empty+add()', () {
    final list = <int>[];
    for (var i = 0; i < size; i++) {
      list.add(i);
    }
  }).report();
  syncBenchmark('List.filled+set[]', () {
    final list = List.filled(size, 0, growable: true);
    for (var i = 0; i < size; i++) {
      list[i] = i;
    }
  }).report();
}

// Compare HashMap and Map elemnt access performance.
void maps() {
  final numbers = List.generate(10000, (i) => i);
  final map = {for (var n in numbers) n: n.toString()};
  final hashMap = HashMap<int, String>.fromEntries(map.entries);
  final randomizedKeys = numbers.toList()..shuffle();
  String? result; // so that the loop isn't optimized out
  syncBenchmark('Map[k]',
          () => randomizedKeys.forEach((index) => result = map[index]))
      .report(units: numbers.length);
  syncBenchmark('HashMap[k]',
          () => randomizedKeys.forEach((index) => result = hashMap[index]))
      .report(units: numbers.length);
  assert(result != null);
}

// Wait for a list of futures that have already been completed.
Future<void> futureWaiting() async {
  final futures = List.generate(1000, (index) => Future.value(index));
  (await asyncBenchmark('Future.wait()', () async => Future.wait(futures)))
      .report();
  (await asyncBenchmark('for loop', () async {
    for (var i = 0; i < futures.length; i++) {
      await futures[i];
    }
  }))
      .report();
}
