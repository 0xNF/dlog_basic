import 'package:dlogbasic/dlogbasic.dart';

/// A logger that discards all messages
class NullLogger extends DLogger {
  const NullLogger({required super.name});

  @override
  bool get isDebugEnabled => true;

  @override
  bool isEnabled(LogLevel level) => true;

  @override
  bool get isErrorEnabled => true;

  @override
  bool get isFatalEnabled => true;

  @override
  bool get isInfoEnabled => true;

  @override
  bool get isTraceEnabled => true;

  @override
  bool get isWarnEnabled => true;

  @override
  void log(dynamic message, {required LogLevel level, Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void trace(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void debug(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void info(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void warn(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void error(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void fatal(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {}

  @override
  void swallow(Function action) {
    try {
      action();
    } finally {}
  }

  @override
  Future<void> swallowAsync(Function action) async {
    try {
      await action();
    } finally {}
  }

  @override
  T? swallowResult<T>(T? Function() action, [T? fallbackValue]) {
    try {
      return action();
    } finally {}
  }

  @override
  Future<T?> swallowResultAsync<T>(Future<T?> Function() action, T? fallbackValue) async {
    try {
      T? res = await action();
      return res;
    } finally {}
  }
}
