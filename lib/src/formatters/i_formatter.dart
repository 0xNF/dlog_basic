import 'dart:convert';

import 'package:dart_ilogger/src/log_event.dart';

/// this class is
abstract class IFormatter {
  const IFormatter();

  String format(LogEvent logEvent);
}

String jsonConvert(Map<String, dynamic>? eventProperties) {
  if (eventProperties == null || eventProperties.isEmpty) {
    return "";
  }
  try {
    final res = _jsonConverter.convert(eventProperties);
    return res;
  } on Exception catch (e) {
    return "<serialization error>: $e";
  }
}

final _jsonConverter = JsonEncoder((val) => val?.toString());
