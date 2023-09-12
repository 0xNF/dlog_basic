import 'dart:convert';

import 'package:dlogbasic/src/formatters/i_formatter.dart';
import 'package:dlogbasic/src/log_event.dart';

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
