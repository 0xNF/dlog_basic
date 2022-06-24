import 'package:dart_ilogger/src/ilogger_base.dart';

/// Represents information about the logger that was reconfigured
///
///  Occurs when logger configuration changes.
class LoggerReconfigured {
  final ILoggerBase loggerBase;

  const LoggerReconfigured({required this.loggerBase});
}
