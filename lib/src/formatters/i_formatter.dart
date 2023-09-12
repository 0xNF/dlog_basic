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
