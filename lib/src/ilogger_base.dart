import 'package:dart_ilogger/src/event_bus/events.dart';
import 'package:dart_ilogger/src/event_bus/event_bus.dart';
import 'package:dart_ilogger/src/log_level.dart';

abstract class ILoggerBase {
  final String name;

  const ILoggerBase({required this.name});

  ///  Writes the diagnostic message at the specified level.
  void log(LogLevel level, dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  ///  Gets a value indicating whether logging is enabled for the specified level.
  bool isEnabled(LogLevel level);

  ///  Occurs when logger configuration changes.
  Stream<LoggerReconfigured> onLoggerReconfigured() {
    return on<LoggerReconfigured>();
  }
}
