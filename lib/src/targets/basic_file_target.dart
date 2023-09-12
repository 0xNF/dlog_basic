import 'dart:io';

import 'package:dlogbasic/dlogbasic.dart';
import 'package:dlogbasic/src/log_event.dart';
import 'package:dlogbasic/src/sinks/file_name_partition.dart';
import 'package:path/path.dart' as path;

void innerLog(LogLevel level, String msg) {
  stderr.writeln('[${DateTime.now()}] [dlogbasic] [$level] $msg');
}

/// This basic target sends output to the file at the path specified, appending to it, formatted with pipes
/// It can be use basic rotating and purging functions, but more complicated usage should come from a more fully featured implementing library like [DLog]
/// this basic writer will flush changes on every write, therefore it is not so efficient.
final class BasicFileTarget extends ITarget<BasicFileSink, IFormatter> {
  String get pathToFile => _pathToFile.filePath;
  FileNamePartition _pathToFile;

  final FileRotationSettings rotationSettings;
  bool isInitd = false;

  BasicFileTarget({
    super.formatter = const BasicFormatter(),
    required String pathToFile,
    this.rotationSettings = const FileRotationSettings(),
  })  : _pathToFile = FileNamePartition.fromFuzzyFilePath(pathToFile),
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
    final rotateOnDate = rotationSettings.rotateOnEvery;
    final partitionDate = partition.datePortion;
    if (rotateOnDate != null) {
      if (partitionDate == null) {
        /* The system glitched and we didn't record a Date on the log file. Rotate it */
        return partition.rolloverDate();
      } else {
        final dateRotatorCheck = partitionDate.add(rotateOnDate);

        if (rotateOnDate.inDays < 1) {
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

  /// Checks whether to rotate a log to a new one
  /// Mutates the isInitd state and sets the new file if so
  /// Runs the delete proceedure if keepHowMany is defined
  bool _checkRotateMut() {
    final rotator = _shouldRotate(rotationSettings, _pathToFile, sink);
    if (rotator != null) {
      _pathToFile = rotator;
      sink.changePathMutSync(rotator.makeFullPath());
      isInitd = false; /* reset the init so we open the new file */
      return true;
    }
    return false;
  }

  /// Deletes old log files that share the same TrueBasename based on the KeepHowMany flag
  Future<void> _deleteOldMut(FileRotationSettings rotationSettings, FileNamePartition currentFilePartition) async {
    final keepHowMany = rotationSettings.keepHowMany;
    if (keepHowMany == null || keepHowMany.isNaN || keepHowMany.isNegative) {
      return;
    }
    Directory d = Directory(path.dirname(currentFilePartition.makeFullPath()));
    final lst = <FileNamePartition>[];
    for (final fse in d.listSync()) {
      if (fse is File) {
        final fsePartition = FileNamePartition.fromFuzzyFilePath(fse.path);
        if (fsePartition.representSameBaseFile(currentFilePartition)) {
          lst.add(fsePartition);
        }
      }
    }

    lst.sort((x, y) => x.compareTo(y));

    /* Keep n-many from the reversed list, because it sorts in ASC order */
    for (final partition in lst.reversed.skip(keepHowMany)) {
      partition.getIOFile().delete().catchError((e) {
        innerLog(LogLevel.warn, 'Failed to delete file, partition no longer existed: $e');
        return e;
      });
    }
  }

  @override
  void writeSync(LogEvent logEvent) {
    final didRotate = _checkRotateMut();
    if (!isInitd) {
      sink.openSync();
      isInitd = true;
    }
    final str = "${formatter.format(logEvent)}\n";
    sink.writeSync(str);
    sink.flushSync();
    if (didRotate) {
      _deleteOldMut(rotationSettings, _pathToFile);
    }
  }

  @override
  Future<void> writeAsync(LogEvent logEvent) async {
    final didRotate = _checkRotateMut();
    if (!isInitd) {
      await sink.openAsync();
      isInitd = true;
    }
    final str = "${formatter.format(logEvent)}\n";
    await sink.writeAsync(str);
    await sink.flushAsync();
    if (didRotate) {
      _deleteOldMut(rotationSettings, _pathToFile);
    }
  }

  @override
  bool shouldWrite(LogEvent logEvent) {
    return true;
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
