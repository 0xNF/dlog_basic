import 'dart:convert';
import 'dart:io';

import 'package:dart_ilogger/dart_ilogger.dart';
import 'package:dart_ilogger/src/sinks/file_name_partition.dart';
import 'package:dart_ilogger/src/sinks/i_sink.dart';

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

class BasicFileSink extends ISink {
  String get pathToFile => _pathToFile;
  String _pathToFile;

  final Encoding encoding;

  /// Total size of the file, used to determine if rollover-on-size is required
  int get writtenBytes => _writtenBytes;
  int _writtenBytes = 0;

  IOSink? _handle;

  BasicFileSink({required String pathToFile, this.encoding = utf8}) : _pathToFile = pathToFile;

  /// Changes the path, for e.g., a file rollover
  /// Closes the existing file if open
  void changePathMutSync(String newPath) {
    closeSync();
    _pathToFile = newPath;
  }

  @override
  void openSync() {
    final partition = FileNamePartition.fromFuzzyFilePath(pathToFile);
    final fpath = partition.makeFullPath();
    final f = File(fpath);
    if (!f.existsSync()) {
      f.createSync(recursive: true);
    }
    _handle = f.openWrite(mode: FileMode.append, encoding: encoding);
    _writtenBytes = f.lengthSync();
  }

  @override
  Future<void> openAsync() async {
    openSync();
  }

  @override
  void closeSync() {
    flushSync();
    _handle?.close();
    _handle = null;
  }

  @override
  Future<void> closeAsync() async {
    closeSync();
  }

  @override
  void writeSync(String formattedMessage) {
    if (_handle == null) {
      throw Exception('File Handle not initialized');
    }
    _writtenBytes += (const Utf8Encoder()).convert(formattedMessage).lengthInBytes;
    _handle!.writeln(formattedMessage);
  }

  @override
  Future<void> writeAsync(String formattedMessage) async {
    writeSync(formattedMessage);
  }

  @override
  void flushSync() {
    _handle?.flush();
  }

  @override
  Future<void> flushAsync() async {
    flushSync();
  }
}
