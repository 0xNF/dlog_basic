import 'dart:convert';

import 'package:dlogbasic/dlogbasic.dart';
import 'package:dlogbasic/src/sinks/file_name_partition.dart';
import 'package:dlogbasic/src/sinks/i_sink.dart';
import 'package:universal_io/io.dart';

class BasicFileSink extends ISink implements IOpenable, IAsyncOpenable, IClosable, IAsyncClosable {
  /// Current file being written to
  FileNamePartition get filePartition => _filePartition;
  FileNamePartition _filePartition;

  /// Encoding of the bytes to write
  final Encoding encoding;

  /// Total size of the file, used to determine if rollover-on-size is required
  int get writtenBytes => _writtenBytes;
  int _writtenBytes = 0;

  RandomAccessFile? _handle;

  BasicFileSink({required String pathToFile, this.encoding = utf8}) : _filePartition = FileNamePartition.fromFuzzyFilePath(pathToFile);

  /// Changes the path, for e.g., a file rollover
  /// Closes the existing file if open
  void changePathMutSync(String newPath) {
    closeSync();
    _filePartition = FileNamePartition.fromFuzzyFilePath(newPath);
  }

  /// Changes the path, for e.g., a file rollover
  /// Closes the existing file if open
  Future<void> changePathMutAsync(String newPath) async {
    await closeAsync();
    _filePartition = FileNamePartition.fromFuzzyFilePath(newPath);
  }

  @override
  void openSync() {
    final fpath = filePartition.makeFullPath();
    final f = File(fpath);
    if (!f.existsSync()) {
      f.createSync(recursive: true, exclusive: false);
    }
    _handle = f.openSync(mode: FileMode.writeOnlyAppend);
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
    final bytes = (encoding.encoder).convert(formattedMessage);
    _writtenBytes += bytes.length;
    _handle?.writeFromSync(bytes);
    // _handle!.add(bytes);
  }

  @override
  Future<void> writeAsync(String formattedMessage) async {
    writeSync(formattedMessage);
  }

  @override
  void flushSync() {
    _handle?.flushSync();
  }

  @override
  Future<void> flushAsync() async {
    await _handle?.flush();
  }
}
