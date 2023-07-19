import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/log_event.dart';

/// This basic target sends output to StdOut formatted with pipes
final class BasicConsoleTarget extends ITarget {
  const BasicConsoleTarget() : super(formatter: const BasicFormatter(), sink: const BasicConsoleSink());

  @override
  void writeSync(LogEvent logEvent) {
    final msg = formatter.format(logEvent);
    sink.writeAsync(msg);
  }

  @override
  Future<void> writeAsync(LogEvent logEvent) async {
    writeSync(logEvent);
  }
}
