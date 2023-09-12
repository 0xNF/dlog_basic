import 'dart:convert';

import 'package:dlogbasic/dlogbasic.dart';
import 'package:dlogbasic/src/log_event.dart';

/// The JsonFormatter is suitable for Structured Logging
///
/// For JSONLine (jsonl) formatting, see the `JsonLinesFormatter`
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
    Map<String, dynamic> data = {
      'Timestamp': logEvent.datetime.millisecondsSinceEpoch,
      'Level': logEvent.level.name,
      'Name': logEvent.loggerName,
    };
    if (logEvent.exception != null) {
      data['Exception'] = logEvent.exception;
    }
    if (logEvent.eventProperties.isNotEmpty) {
      data['EventProperties'] = logEvent.eventProperties;
    }

    final m = keyReplacer(logEvent, const JsonEncoder().convert);

    data['Message'] = m;

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}

/// The JsonLinesFormatter is suitable for Structured Logging
///
/// For standard json  formatting, see the `JsonFormatter`
///
/// it returns a log object of the following specification, on line line
///
/// {'Timestamp': MS-Since-Epoch Unix time, 'Level': String, 'Name': String, 'Message: String, 'Exception': String?, 'EventProperties': JsonObject?}
class JsonLinesFormatter implements IFormatter {
  const JsonLinesFormatter();

  @override
  String format(LogEvent logEvent) {
    Map<String, dynamic> data = {
      'Timestamp': logEvent.datetime.millisecondsSinceEpoch,
      'Level': logEvent.level.name,
      'Name': logEvent.loggerName,
    };
    if (logEvent.exception != null) {
      data['Exception'] = logEvent.exception;
    }
    if (logEvent.eventProperties.isNotEmpty) {
      data['EventProperties'] = logEvent.eventProperties;
    }

    final m = keyReplacer(logEvent, const JsonEncoder().convert);

    data['Message'] = m;

    return jsonConvert(data);
  }
}
