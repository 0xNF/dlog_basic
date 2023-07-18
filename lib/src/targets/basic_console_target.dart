import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/log_event.dart';
import 'package:dart_ilogger/src/sinks/file_name_partition.dart';

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

/// This basic target sends output to the file at the path specified, appending to it, formatted with pipes
/// It can be use basic rotating and purging functions, but more complicated usage should come from a more fully featured implementing library like [DLog]
/// this basic writer will flush changes on every write, therefore it is not so efficient.
final class BasicFileTarget extends ITarget<BasicFileSink, IFormatter> {
  String get pathToFile => _pathToFile;
  String _pathToFile;
  final FileRotationSettings rotationSettings;
  bool isInitd = false;

  BasicFileTarget({
    super.formatter = const BasicFormatter(),
    required String pathToFile,
    this.rotationSettings = const FileRotationSettings(),
  })  : _pathToFile = pathToFile,
        super(
          sink: BasicFileSink(
            pathToFile: pathToFile,
          ),
        );

  /// If rotation is necessary, returns a new `FileNamePartition` with the adjusted apenders
  /// If one is not necessary, returns `null`
  static FileNamePartition? _shouldRotate(FileRotationSettings rotationSettings, FileNamePartition partition, BasicFileSink sink) {
    final now = DateTime.now();
    if (rotationSettings.rotateOnByteSize != null && sink.writtenBytes >= rotationSettings.rotateOnByteSize!) {
      return partition.rolloverIncrement();
    }
    final every = rotationSettings.rotateOnEvery;
    final partitionDate = partition.datePortion;
    if (every != null) {
      if (partitionDate == null) {
        /* The system glitched and we didn't record a Date on the log file. Rotate it */
        return partition.rolloverDate();
      } else {
        final dateRotatorCheck = partitionDate.add(every);

        if (every.inDays < 1) {
          /* This basic logger doesn't handle granularity underneath a day. Don't rotate just to be safe */
          return null;
        } else if (now.isAfter(dateRotatorCheck)) {
          /* File Creation Time is earlier than the rotator, should rotate */
          return partition.rolloverDate();
        }
      }
    }
    return null;
  }

  @override
  void writeSync(LogEvent logEvent) {
    var partition = FileNamePartition.fromFuzzyFilePath(pathToFile);
    final rotator = _shouldRotate(rotationSettings, partition, sink);
    if (rotator != null) {
      sink.changePathMutSync(rotator.makeFullPath());
      isInitd = false; /* reset the init so we open the new file */
    }
    if (!isInitd) {
      sink.openSync();
      isInitd = true;
    }
    final str = "${formatter.format(logEvent)}\n";
    sink.writeSync(str);
    sink.flushSync();
  }

  @override
  Future<void> writeAsync(LogEvent logEvent) async {
    var partition = FileNamePartition.fromFuzzyFilePath(pathToFile);
    final rotator = _shouldRotate(rotationSettings, partition, sink);
    if (rotator != null) {
      sink.changePathMutSync(rotator.makeFullPath());
      isInitd = false; /* reset the init so we open the new file */
    }
    if (!isInitd) {
      await sink.openAsync();
      isInitd = true;
    }
    final str = "${formatter.format(logEvent)}\n";
    await sink.writeAsync(str);
    await sink.flushAsync();
  }
}

class FileRotationSettings {
  /// Rotate the log file every time this duration has passed from initial write
  /// If null, do not rotate on time
  final Duration? rotateOnEvery;

  /// Rotate the log file when it reaches this many bytes written
  /// If null, do not rotate on byte size
  final int? rotateOnByteSize;

  /// Keep this many past log files around
  /// if null or negative, keep infinite log files.
  /// If zero, keep no log files at all
  final int? keepHowMany;

  const FileRotationSettings({this.rotateOnEvery, this.rotateOnByteSize, this.keepHowMany});
}
