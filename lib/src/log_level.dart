import 'package:collection/collection.dart';

/// Which log level to write with, from [LogLevel.trace] (most noisy) to [LogLevel.fatal] (least noisy)
class LogLevel {
  final String name;
  final int ordinal;

  LogLevel({required this.name, required this.ordinal}) {
    if (_values.any((e) => e.ordinal == ordinal)) {
      throw Exception("A log level was created with the same `ordinal` as one that already exists. Please ensure these ordinals are unique");
    }
    _values.add(this);
  }

  @override
  String toString() {
    return name;
  }

  static List<LogLevel> get values => List.unmodifiable(_values);
  static final List<LogLevel> _values = [];

  /// For very detailed messages. These may be produced by the thousands or more
  static LogLevel trace = LogLevel(name: "Trace", ordinal: 0);

  /// For small messages useful for debugging
  static LogLevel debug = LogLevel(name: "Debug", ordinal: 1);

  /// General purpose messages with no specific urgency
  static LogLevel info = LogLevel(name: "Info", ordinal: 2);

  /// Messages to keep an eye on, such as system faults or places that may become a problem in the future
  static LogLevel warn = LogLevel(name: "Warn", ordinal: 3);

  /// Messages for things that failed, but not in a way that brings the system down
  static LogLevel error = LogLevel(name: "Error", ordinal: 4);

  /// Messages documenting things that should stop the system completely
  static LogLevel fatal = LogLevel(name: "Fatal", ordinal: 5);

  static LogLevel? fromOrdinal(int i) {
    return _values.firstWhereOrNull((l) => l.ordinal == i);
  }

  static LogLevel? fromString(String s) {
    return _values.firstWhere((l) => l.name.toLowerCase() == s.toLowerCase());
  }

  static LogLevel get minLevel => _values.fold(fatal, (previousValue, element) => previousValue.ordinal > element.ordinal ? previousValue : element);
  static LogLevel get maxLevel => _values.fold(debug, (previousValue, element) => previousValue.ordinal < element.ordinal ? previousValue : element);
}
