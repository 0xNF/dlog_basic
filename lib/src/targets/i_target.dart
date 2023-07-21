import 'package:dart_ilogger/src/log_event.dart';
import 'package:dart_ilogger/src/sinks/i_sink.dart';
import 'package:dart_ilogger/src/formatters/i_formatter.dart';

/// A target is a combination of WHERE to write (sink)
/// and WHAT to write (writer)
///
/// input => formatter => sink
/// `sink.write(formatter.format(logEvent))`
abstract class ITarget<S extends ISink, F extends IFormatter> {
  final F formatter;
  final S sink;

  const ITarget({required this.formatter, required this.sink});

  /// Formats the log event and writes to the sink asychronously. Not required.
  ///
  /// For async, see [writeAsync]
  void writeSync(LogEvent logEvent) {
    throw Exception('This target does not implement `writeSync`');
  }

  /// Formats the log event and writes to the sink asychronously. Required.
  ///
  /// For sync, see [writeSync]
  Future<void> writeAsync(LogEvent logEvent);

  /// Whether this log event should be written to this logger
  bool shouldWrite(LogEvent logEvent);
}
