import 'package:dlogbasic/src/event_bus/events.dart';
import 'package:dlogbasic/src/event_bus/event_bus.dart';
import 'package:dlogbasic/src/targets/i_target.dart';
import 'package:ilogger/ilogger.dart';

abstract class ILoggerBase {
  final String name;

  final List<ITarget> targets;

  const ILoggerBase({
    required this.name,
    this.targets = const [],
  });

  ///  Gets a value indicating whether logging is enabled for the specified level.
  bool isEnabled(LogLevel level);

  ///  Occurs when logger configuration changes.
  Stream<LoggerReconfigured> onLoggerReconfigured() {
    return on<LoggerReconfigured>();
  }
}
