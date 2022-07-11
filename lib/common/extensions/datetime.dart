// ignore_for_file: non_constant_identifier_names

extension on int {
  String toFixedString(int length) {
    String ret = '$this';
    if (ret.length < length) {
      ret = '0' * (length - ret.length) + ret;
    }
    return ret;
  }
}

extension DateTimeExtension on DateTime {
  String get YYmmddHHMMSS {
    return "$year-${month.toFixedString(2)}-${day.toFixedString(2)} ${hour.toFixedString(2)}:${minute.toFixedString(2)}:${second.toFixedString(2)}";
  }

  String get YYmmdd {
    return "$year-${month.toFixedString(2)}-${day.toFixedString(2)}";
  }

  String get YYmm {
    return "$year-${month.toFixedString(2)}";
  }

  String get hhmm {
    return "${hour.toFixedString(2)}:${minute.toFixedString(2)}";
  }

  String get mmdd {
    return "${month.toFixedString(2)}-${day.toFixedString(2)}";
  }

  String get smartFormat {
    DateTime now = DateTime.now();
    if (now.difference(this).inDays > 0) {
      if (now.year == year) {
        return mmdd;
      }
      return YYmmdd;
    }
    return hhmm;
  }
}
