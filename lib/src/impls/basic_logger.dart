import 'dart:convert';

import 'package:dart_ilogger/dart_ilogger.dart';

final _jsonConverter = JsonEncoder((val) => val?.toString());

String _jsonConvert(Map<String, dynamic>? eventProperties) {
  if (eventProperties == null) {
    return "";
  }
  try {
    final res = _jsonConverter.convert(eventProperties);
    return res;
  } on Exception catch (e) {
    return "<serialization error>";
  }
}

class BasicLogger extends ILogger {
  const BasicLogger({required super.name});

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
    final exceptionStr = exception == null ? "" : " ${exception.toString()} ";
    final eventPropString = _jsonConvert(eventProperties);
    String m = message.toString();
    if (eventProperties != null) {
      for (final kvp in eventProperties.entries) {
        String vl;
        if (kvp.value is String) {
          vl = kvp.value as String;
        } else {
          try {
            vl = const JsonEncoder().convert(kvp.value);
          } catch (e) {
            vl = kvp.value.toString();
          }
        }
        m = m.replaceAll('{${kvp.key}}', vl);
      }
    }
    print("[${DateTime.now()}] [${level.name}] [${super.name}] $m |$exceptionStr|$eventPropString");
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
