import 'dart:convert';

import 'package:dart_ilogger/src/formatters/i_formatter.dart';
import 'package:dart_ilogger/src/log_event.dart';

/// The BasicFormatter formats messages like so:
///
/// `[$DateTime] [$LogLevel] [LoggerName] $message |$exception||$eventProperties`
///
/// It is not appropriate for structured logging but it is good for simple console output
class BasicFormatter implements IFormatter {
  const BasicFormatter();

  @override
  String format(LogEvent logEvent) {
    final exceptionStr = logEvent.exception == null ? "" : " ${logEvent.exception.toString()} ";
    final eventPropString = jsonConvert(logEvent.eventProperties);
    String m = logEvent.message.toString();
    if (logEvent.eventProperties.isNotEmpty) {
      for (final kvp in logEvent.eventProperties.entries) {
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

    final msg = "[${logEvent.datetime}] [${logEvent.level.name}] [${logEvent.loggerName}] $m |$exceptionStr|$eventPropString";

    return msg;
  }
}

/// The JsonFormatter is suitable for Structured Logging
///
/// it returns a log object of the following specification:
///
/// {
///   'Timestamp': MS-Since-Epoch Unix time,
///   'Level': String,
///   'Name': String
///   'Message: String,
///   'Exception': String?,
///   'EventProperties': JsonObject?
/// }
class JsonFormatter implements IFormatter {
  const JsonFormatter();

  @override
  String format(LogEvent logEvent) {
    Map<String, dynamic> jsonMap = {
      'Timestamp': logEvent.datetime.millisecondsSinceEpoch,
      'Level': logEvent.level.name,
      'Name': logEvent.loggerName,
      'Message': logEvent.message,
    };
    if (logEvent.exception != null) {
      jsonMap['Exception'] = logEvent.exception;
    }
    if (logEvent.eventProperties.isNotEmpty) {
      jsonMap['EventProperties'] = logEvent.eventProperties;
    }

    return jsonConvert(jsonMap);
  }
}
