import 'package:dlogbasic/dlogbasic.dart';
import 'package:dlogbasic/src/log_event.dart';

class BasicLogger extends DLogger {
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
  void log(dynamic message, {required LogLevel level, Exception? exception, Map<String, dynamic>? eventProperties}) {
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
        if (target.shouldWrite(logEvent)) {
          target.writeSync(logEvent);
        }
      }
    }
  }

  @override
  void trace(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.trace, exception: exception, eventProperties: eventProperties);
  }

  @override
  void debug(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.debug, exception: exception, eventProperties: eventProperties);
  }

  @override
  void info(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.info, exception: exception, eventProperties: eventProperties);
  }

  @override
  void warn(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.warn, exception: exception, eventProperties: eventProperties);
  }

  @override
  void error(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.error, exception: exception, eventProperties: eventProperties);
  }

  @override
  void fatal(message, {Exception? exception, Map<String, dynamic>? eventProperties}) {
    log(message, level: LogLevel.fatal, exception: exception, eventProperties: eventProperties);
  }
}
