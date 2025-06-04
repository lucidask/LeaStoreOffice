class DurationParser {
  static Duration parse(String input) {
    final regex = RegExp(r'(\d+)\s*(h|m|s)');
    final matches = regex.allMatches(input.toLowerCase());

    int hours = 0, minutes = 0, seconds = 0;

    for (final match in matches) {
      final value = int.parse(match.group(1)!);
      final unit = match.group(2)!;

      switch (unit) {
        case 'h':
          hours += value;
          break;
        case 'm':
          minutes += value;
          break;
        case 's':
          seconds += value;
          break;
      }
    }

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}
