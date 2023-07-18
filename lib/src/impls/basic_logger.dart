import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/log_event.dart';
import 'package:dart_ilogger/src/targets/basic_console_target.dart';

class BasicLogger extends ILogger {
  const BasicLogger({
    required super.name,
    super.targets = const [
      BasicConsoleTarget(),
    ],
  });

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
  void log(LogLevel level, message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    if (isEnabled(level)) {
      final LogEvent logEvent = LogEvent(
        loggerName: super.name,
        datetime: DateTime.now(),
        level: level,
        message: message,
        eventProperties: eventProperties ?? {},
        exception: exception,
      );

      for (final target in super.targets) {
        target.writeSync(logEvent);
      }
    }
  }

  @override
  void trace(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.trace, message, exception: exception, eventProperties: eventProperties);
  }

  @override
  void debug(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.debug, message, exception: exception, eventProperties: eventProperties);
  }

  @override
  void info(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.info, message, exception: exception, eventProperties: eventProperties);
  }

  @override
  void warn(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.warn, message, exception: exception, eventProperties: eventProperties);
  }

  @override
  void error(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.error, message, exception: exception, eventProperties: eventProperties);
  }

  @override
  void fatal(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(LogLevel.fatal, message, exception: exception, eventProperties: eventProperties);
  }
}
