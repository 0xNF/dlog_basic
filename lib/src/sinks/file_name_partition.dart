import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:path/path.dart' as path;

final class FileNamePartition {
  static const String _dateDelimeter = '_';
  static const String _incrementerDelimeter = '-';
  static const String _extensionDelimeter = '.';
  static const String _datePadder = '0';

  /// Absolute or relative path to the file, without filenames
  /// e.g.,, '/users/nf/myfile.txt' => '/users/nf/'
  final String filePathNoFilename;

  /// Absolute or relative path to the file, including the filename and extension
  final String filePath;

  /// basename of the file, without extension
  final String filename;

  /// Extension of the file, such as 'txt' or 'md'
  final String? extension;

  /// Name of this file without DLogSimple specific datetime and incrementer appendages
  /// i.e., 'MyLog-2020-07-20-2.txt' => 'MyLog'
  final String trueBasename;

  /// DateTime that is encoded into the filename,
  /// i.e., 'MyLog-2020-07-20.txt' -> DateTime(2020, 07, 20)
  final DateTime? datePortion;

  /// Incremener portion encoded into filename,
  /// i.e., 'MyLog-2.txt' -> 2
  final int? incrementPortion;

  const FileNamePartition({
    required this.filePathNoFilename,
    required this.filePath,
    required this.filename,
    required this.trueBasename,
    required this.extension,
    required this.datePortion,
    required this.incrementPortion,
  });

  /// Creates a FileNamePartition from the given path, decoding date increment portions if present
  factory FileNamePartition.fromFuzzyFilePath(String fpath) {
    final basename = path.basenameWithoutExtension(fpath);
    final dir = path.dirname(fpath);
    final ext = path.extension(fpath);

    final splits = basename.split(_dateDelimeter);

    /* Get the last DateTime and Incrementer from the filename */
    DateTime? lastDateTime;
    int? lastIncrement;
    if (splits.length > 1) {
      final last = splits.last;
      final lastSplits = last.split(_incrementerDelimeter);
      if (lastSplits.length == 3 || lastSplits.length == 4) {
        final yearMaybe = lastSplits[0];
        final monthMaybe = lastSplits[1];
        final dayMaybe = lastSplits[2];

        lastDateTime = DateTime.tryParse("$yearMaybe-$monthMaybe-$dayMaybe");
        if (lastDateTime != null && lastSplits.length == 4) {
          lastIncrement = int.tryParse(lastSplits.last);
        }
      } else {
        final lastSplits = splits.last.split(_incrementerDelimeter);
        lastIncrement = int.tryParse(lastSplits.last);
      }
    }

    String trueBaseName = basename;
    if (lastIncrement != null) {
      final lenIncr = 1 + lastIncrement.toString().length; /* +1 for the leading dash */
      trueBaseName = trueBaseName.substring(0, trueBaseName.length - lenIncr);
    }
    if (lastDateTime != null) {
      final lenDt = 1 + stringifyDateTime(lastDateTime).length; /* +1 for leading underscore */
      trueBaseName = trueBaseName.substring(0, trueBaseName.length - lenDt);
    }

    return FileNamePartition(
      filePathNoFilename: dir,
      filePath: fpath,
      filename: basename,
      trueBasename: trueBaseName,
      extension: ext,
      datePortion: lastDateTime,
      incrementPortion: lastIncrement,
    );
  }

  /// Returns the filename, without directory information, of this partition.
  /// Includes extension, datetime, and incremener portions if not null
  /// e.g. => MyLog-2020-07-20-2.txt
  String makeFileName() {
    StringBuffer sb = StringBuffer(trueBasename);

    if (datePortion != null) {
      sb.write(_dateDelimeter);
      sb.write(stringifyDateTime(datePortion!));
    }
    if (incrementPortion != null) {
      sb.write(_incrementerDelimeter);
      sb.write(incrementPortion!.toString());
    }

    if (extension != null && extension!.isNotEmpty) {
      sb.write(_extensionDelimeter);
      sb.write(extension!);
    }

    return sb.toString();
  }

  /// Returns the filename of this Partition, with the entire leading directory structure, if present
  String makeFullPath() {
    final fname = makeFileName();
    final p = path.join(filePathNoFilename, fname);
    return p;
  }

  static String stringifyDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, _datePadder)}-${dt.day.toString().padLeft(2, _datePadder)}";
  }

  FileNamePartition rolloverDate({DateTime? setAs}) {
    return cloneWith(datePortion: setAs ?? DateTime.now());
  }

  FileNamePartition rolloverIncrement({int? setAs}) {
    int? incr;
    if (setAs != null) {
      if (setAs.isNegative || setAs.isNaN) {
        incr = 1;
      } else {
        incr = setAs;
      }
    } else {
      if (incrementPortion == null || incrementPortion!.isNegative || incrementPortion!.isNaN) {
        incr = 1;
      } else {
        incr = incrementPortion! + 1;
      }
    }
    return cloneWith(incrementPortion: incr);
  }

  FileNamePartition cloneWith({
    String? filePathNoFilename,
    String? filePath,
    String? filename,
    String? trueBasename,
    String? extension,
    DateTime? datePortion,
    int? incrementPortion,
  }) {
    return FileNamePartition(
      filePathNoFilename: filePathNoFilename ?? this.filePathNoFilename,
      filePath: filePath ?? this.filePath,
      filename: filename ?? this.filename,
      trueBasename: trueBasename ?? this.trueBasename,
      extension: extension ?? this.extension,
      datePortion: datePortion ?? this.datePortion,
      incrementPortion: incrementPortion ?? this.incrementPortion,
    );
  }
}
