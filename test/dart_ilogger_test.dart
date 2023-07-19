import 'dart:io';

import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/sinks/file_name_partition.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group("Test sort order of old logs", () {
    test("test sort: only increment", () {
      final lst = <FileNamePartition>[
        FileNamePartition.fromFuzzyFilePath("sample.txt"),
        FileNamePartition.fromFuzzyFilePath("sample-1.txt"),
        FileNamePartition.fromFuzzyFilePath("sample-4.txt"),
        FileNamePartition.fromFuzzyFilePath("sample-2.txt"),
      ];

      lst.sort((x, y) {
        return x.compareTo(y);
      });

      expect(lst.first.filename, "sample");
      expect(lst[1].filename, "sample-1");
      expect(lst[2].filename, "sample-2");
      expect(lst[3].filename, "sample-4");
    });

    test("test sort: only date", () {
      final lst = <FileNamePartition>[
        FileNamePartition.fromFuzzyFilePath("sample_2012-06-20.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2012-07-20.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2013-07-20.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2012-06-21.txt"),
      ];

      lst.sort((x, y) {
        return x.compareTo(y);
      });

      expect(lst[0].datePortion, DateTime(2012, 06, 20));
      expect(lst[1].datePortion, DateTime(2012, 06, 21));
      expect(lst[2].datePortion, DateTime(2012, 07, 20));
      expect(lst[3].datePortion, DateTime(2013, 07, 20));
    });

    test("test sort: date and increment", () {
      final lst = <FileNamePartition>[
        FileNamePartition.fromFuzzyFilePath("sample_2013-07-20-3.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2012-06-20-2.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2012-06-20-1.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2013-07-20-1.txt"),
        FileNamePartition.fromFuzzyFilePath("sample_2010-07-21.txt"),
      ];

      lst.sort((x, y) {
        return x.compareTo(y);
      });

      expect(lst[0].datePortion, DateTime(2010, 07, 21));
      expect(lst[0].incrementPortion, null);

      expect(lst[1].datePortion, DateTime(2012, 06, 20));
      expect(lst[1].incrementPortion, 1);

      expect(lst[2].datePortion, DateTime(2012, 06, 20));
      expect(lst[2].incrementPortion, 2);

      expect(lst[3].datePortion, DateTime(2013, 07, 20));
      expect(lst[3].incrementPortion, 1);

      expect(lst[4].datePortion, DateTime(2013, 07, 20));
      expect(lst[4].incrementPortion, 3);
    });
  });

  group('Basic Console Tests', () {
    final _logger = BasicLogger(name: 'ConsoleTestLogger');

    setUp(() {});

    test('Test console', () {
      _logger.info("Test console");
    });

    test("Test console with eprops", () {
      _logger.info("Test console eprops", eventProperties: {'keya': 'valuea'});
    });

    test("Test console with eprops substitute", () {
      _logger.info('Test console eprops substitute: val: {keya}', eventProperties: {'keya': 'valuea'});
    });

    test("Test console with exception", () {
      var e = FormatException('some fmterr');
      _logger.error('Test console with exception', exception: e);
    });
  });

  group("Basic File Tests", () {
    const logpath = "ilogger_test.txt";
    var bft = BasicFileTarget(pathToFile: logpath);
    var logger = BasicLogger(name: 'FileTestLogger', targets: [
      bft,
    ]);
    final f = File(logpath);

    void clearTemp() {
      try {
        final p1 = FileNamePartition.fromFuzzyFilePath(f.path);
        final dirname = path.dirname(logpath);
        Directory d = Directory(dirname);
        for (final fse in d.listSync()) {
          if (fse is File) {
            final p2 = FileNamePartition.fromFuzzyFilePath(fse.path);
            if (p2.representSameBaseFile(p1)) {
              fse.deleteSync();
            }
          }
        }
      } on PathNotFoundException catch (_) {
        return;
      }
    }

    setUp(() {
      clearTemp();
    });

    test("Write one line", () async {
      logger.info('Basic Message lmao2');
      final lines = await f.readAsLines();
      expect(lines.length, 1, reason: 'log lines should have been length 1');
    });

    test("Write multiple lines", () async {
      logger.trace('line -1');
      logger.debug('line 0');
      logger.info('line 1');
      logger.warn('line2');
      logger.error('line3');
      logger.fatal('line4');

      final lines = await f.readAsLines();
      expect(lines.length, 6, reason: 'log lines should have been length 6');
      expect(lines.first, contains('[Trace]'), reason: 'first log line should have been "trace"');
      expect(lines.last, contains('[Fatal]'), reason: 'last log line should have been "fatal"');
    });

    test("Rollover file on byte size", () async {
      const size = 100000;

      bft = BasicFileTarget(pathToFile: logpath, rotationSettings: FileRotationSettings(rotateOnByteSize: size ~/ 2));
      logger = BasicLogger(name: 'FileTestLogger', targets: [
        bft,
      ]);

      /* Write the first big string */
      final bigStr = "a" * size;
      logger.info(bigStr);
      /* Write the second big string, which should force a rollover b/c of the 50kb limit */
      logger.info(bigStr);

      final partition = FileNamePartition.fromFuzzyFilePath(logpath).rolloverIncrement();
      final bytesF1 = await f.readAsBytes();
      final bytesF2 = await partition.getIOFile().readAsBytes();
      expect(bytesF1.lengthInBytes, closeTo(size, size * .1));
      expect(bytesF2.lengthInBytes, closeTo(size, size * .1));
    });

    test("Rollover file on date", () async {
      bft = BasicFileTarget(pathToFile: logpath, rotationSettings: FileRotationSettings(rotateOnEvery: Duration(days: 1)));
      logger = BasicLogger(name: 'FileTestLogger', targets: [
        bft,
      ]);

      logger.info('line one file one');

      /* hack to set the log file back a day */
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      final partition1 = FileNamePartition.fromFuzzyFilePath(logpath).rolloverDate(setAs: yesterday);
      final partition2 = partition1.rolloverDate();

      File f1 = bft.sink.filePartition.getIOFile();
      await bft.sink.changePathMutAsync(partition1.makeFullPath());
      f1 = await f1.rename(partition1.makeFileName());

      await bft.sink.openAsync();

      logger.info('line one file two');

      /* check contents */
      final f2 = partition2.getIOFile();
      final linesF1 = await f1.readAsLines();
      final linesF2 = await f2.readAsLines();

      expect(linesF1.first, contains('file one'));
      expect(linesF2.first, contains('file two'));
      expect(f1.path, contains(FileNamePartition.stringifyDateTime(yesterday)));
      expect(f2.path, contains(FileNamePartition.stringifyDateTime(today)));

      bft.sink.closeSync();

      f1.deleteSync();
      f2.deleteSync();
    });
  });
}
