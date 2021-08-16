import 'dart:math';

/// Console printer for benchmark results.
class Printer {
  const Printer();

  void blank() => print('');

  void plain(dynamic value) => print(autoTransform(value));

  void labeled(String label, dynamic value, {Color color = Color.none}) {
    label = lpad(label, 20) + ': ';
    value = autoTransform(value);
    return color == Color.none
        ? print('$label$value')
        : print('$label$color$value${Color._reset}');
  }

  void colored(Color color, dynamic value) {
    value = autoTransform(value);
    return color == Color.none
        ? print(value)
        : print('$color$value${Color._reset}');
  }

  static String autoTransform(dynamic value) =>
      value is num ? format(value) : value.toString();

  /// Simple number formatting
  /// * the smaller the number, the more decimal places it has.
  /// * large numbers use thousands separator (non-breaking space by default).
  static String format(num number,
      {String thousandsSeparator = ' ',
      int? decimalPoints,
      String suffix = '   ',
      int lPadLength = 8}) {
    late String str;

    if (number.isInfinite) {
      return lpad(number.toString(), lPadLength);
    }
    assert(number >= 0);
    decimalPoints ??=
        number is int ? 0 : max(0, 5 - number.toStringAsFixed(0).length);
    str = number.toStringAsFixed(decimalPoints);

    if (number >= 1000 && thousandsSeparator.isNotEmpty) {
      // add thousands separators, efficiency doesn't matter here...
      final parts = str.split('.');
      final digitsReversed =
          parts[0].split('').reversed.toList(growable: false);
      str = parts.length == 1 ? '' : '.${parts[1]}';
      for (var i = 0; i < digitsReversed.length; i++) {
        if (i > 0 && i % 3 == 0) str = '$thousandsSeparator$str';
        str = '${digitsReversed[i]}$str';
      }
    }

    return lpad(str, lPadLength) + suffix;
  }

  static String formatMicroseconds(num number) => number < 1000
      ? format(number, suffix: ' μs')
      : number < 1000000
          ? format(number / 1000, suffix: ' ms')
          : format(number / 1000000, suffix: '  s');

  static String lpad(String text, int length) {
    while (text.length < length) {
      text = ' $text';
    }
    return text;
  }
}

/// Console color modifiers.
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
