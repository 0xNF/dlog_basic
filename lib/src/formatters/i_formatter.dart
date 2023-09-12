import 'dart:convert';

import 'package:dlogbasic/src/log_event.dart';

/// this class is
abstract class IFormatter {
  const IFormatter();

  String format(LogEvent logEvent);
}

String jsonConvert(Map<String, dynamic>? jsonMap) {
  if (jsonMap == null || jsonMap.isEmpty) {
    return "";
  }
  try {
    final res = _jsonConverter.convert(jsonMap);
    return res;
  } on Exception catch (e) {
    return "<serialization error>: $e";
  }
}

final _jsonConverter = JsonEncoder((val) => val?.toString());

String keyReplacer(LogEvent logEvent, String Function(Object? any) valueConverter) {
  String m = logEvent.message.toString();
  if (logEvent.eventProperties.isNotEmpty) {
    for (final kvp in logEvent.eventProperties.entries) {
      String vl;
      if (kvp.value is String) {
        vl = kvp.value as String;
      } else {
        try {
          vl = valueConverter(kvp.value); //const JsonEncoder().convert(kvp.value);
        } catch (e) {
          vl = kvp.value.toString();
        }
      }
      m = m.replaceAll('{${kvp.key}}', vl);
    }
  }
  return m;
}
