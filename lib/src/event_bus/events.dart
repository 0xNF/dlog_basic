import 'package:dlogbasic/src/dlogger_base.dart';

/// Represents information about the logger that was reconfigured
///
///  Occurs when logger configuration changes.
class LoggerReconfigured {
  final DLoggerBase loggerBase;

  const LoggerReconfigured({required this.loggerBase});
}
