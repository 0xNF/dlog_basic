import 'dart:convert';

import 'package:dart_ilogger/src/formatters/i_formatter.dart';
import 'package:dart_ilogger/src/log_event.dart';

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

    final msg = "[${DateTime.now()}] [${logEvent.level.name}] [${logEvent.loggerName}] $m |$exceptionStr|$eventPropString";

    return msg;
  }
}
