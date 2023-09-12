import 'package:ilogger/ilogger.dart';

final class LogEvent {
  final String loggerName;
  final DateTime datetime;
  final LogLevel level;
  final Exception? exception;
  final Map<String, dynamic> eventProperties;
  final String message;

  const LogEvent({
    required this.loggerName,
    required this.datetime,
    required this.level,
    required this.message,
    this.eventProperties = const {},
    this.exception,
  });
}
