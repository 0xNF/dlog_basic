import 'package:dart_ilogger/src/event_bus/events.dart';
import 'package:dart_ilogger/src/event_bus/event_bus.dart';
import 'package:dart_ilogger/src/log_level.dart';
import 'package:dart_ilogger/src/targets/i_target.dart';

abstract class ILoggerBase {
  final String name;

  final List<ITarget> targets;

  const ILoggerBase({
    required this.name,
    this.targets = const [],
  });

  ///  Writes the diagnostic message at the specified level.
  void log(LogLevel level, dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  ///  Gets a value indicating whether logging is enabled for the specified level.
  bool isEnabled(LogLevel level);

  ///  Occurs when logger configuration changes.
  Stream<LoggerReconfigured> onLoggerReconfigured() {
    return on<LoggerReconfigured>();
  }
}
