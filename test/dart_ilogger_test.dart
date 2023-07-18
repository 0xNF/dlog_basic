import 'dart:io';

import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/sinks/file_name_partition.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
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
            if (p2.hasSameBasename(p1)) {
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
      final bytesF2 = await (File(partition.makeFullPath())).readAsBytes();
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
      var testPartition = FileNamePartition.fromFuzzyFilePath(logpath).rolloverDate(setAs: DateTime.now().subtract(Duration(days: 1)));
      await f.rename(testPartition.makeFileName());

      logger.info('line one file two');

      /* check contents */
      final linesF1 = await f.readAsLines();
      final linesF2 = await (File(testPartition.makeFullPath())).readAsLines();
      expect(linesF1, contains('file one'));
      expect(linesF2, contains('file two'));

      /* check partitions */
      final partition1 = FileNamePartition.fromFuzzyFilePath(logpath);
      final partition2 = FileNamePartition.fromFuzzyFilePath(fpath)
    });
  });
}
