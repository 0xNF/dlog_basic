import 'package:dlogbasic/dlogbasic.dart';
import 'package:dlogbasic/src/sinks/i_sink.dart';

class BasicConsoleSink extends ISink {
  const BasicConsoleSink();

  @override
  void writeSync(String formattedMessage) {
    print(formattedMessage);
  }

  @override
  Future<void> writeAsync(String formattedMessage) async {
    writeSync(formattedMessage);
  }
}
