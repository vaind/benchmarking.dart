import 'dart:math';

class Printer {
  void blank() => print('');

  void plain(dynamic value) => print(value);

  void colored(Color color, dynamic value) =>
      color == Color.none ? print(value) : print('$color$value${Color._reset}');

  /// Simple number formatting
  /// * the smaller the number, the more decimal places it has.
  /// * large numbers use thousands separator (non-breaking space by default).
  static String format(num number,
      {String thousandsSeparator = ' ',
      int? decimalPoints,
      String suffix = '   ',
      int lPadLength = 10}) {
    assert(number >= 0);
    decimalPoints ??=
        number is int ? 0 : max(0, 5 - number.toStringAsFixed(0).length);
    var str = number.toStringAsFixed(decimalPoints);

    if (number >= 1000) {
      // add thousands separators, efficiency doesn't matter here...
      final digitsReversed = str.split('').reversed.toList(growable: false);
      str = '';
      for (var i = 0; i < digitsReversed.length; i++) {
        if (i > 0 && i % 3 == 0) str = '$thousandsSeparator$str';
        str = '${digitsReversed[i]}$str';
      }
    }

    str += suffix;

    while (str.length < lPadLength) {
      str = ' $str';
    }

    return str;
  }
}

class Color {
  final String _value;
  const Color._(this._value);

  static const black = Color._('\x1b[30m');
  static const red = Color._('\x1b[31m');
  static const green = Color._('\x1b[32m');
  static const yellow = Color._('\x1b[33m');
  static const blue = Color._('\x1b[34m');
  static const magenta = Color._('\x1b[35m');
  static const cyan = Color._('\x1b[36m');
  static const white = Color._('\x1b[37m');
  static const none = Color._('');

  static const _reset = Color._('\x1b[0m');

  @override
  String toString() => _value;
}
