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

    final m = keyReplacer(logEvent, const JsonEncoder().convert);

    final msg = "[${logEvent.datetime}] [${logEvent.level.name}] [${logEvent.loggerName}] $m |$exceptionStr|$eventPropString";

    return msg;
  }
}
