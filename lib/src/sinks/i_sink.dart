/// Represents something that receives strings. Can be a file, a stdout console, a database connection, etc
/// Implementors of this class are only responsible for opening, closing, and sending bytes.
abstract class ISink {
  const ISink();

  /// Writes the final message to the sink. Not all writers require this.
  /// For async write, see [writeAsync]
  void writeSync(String formattedMessage) {
    throw UnimplementedError("This ISink does not implement `writeSync`");
  }

  /// Writes the final message to the sink. Required. Often just delegates to writeSync
  /// For sync write, see [writeSync]
  Future<void> writeAsync(String formattedMessage);

  /// Flushes any pending changes to this sink. Not all writers require this.
  ///
  /// For async flush, see [flushAsync]
  void flushSync() {
    throw UnimplementedError("This ISink does not implement `flushSync`");
  }

  /// Flushes any pending changes to this sink asynchronously. Not all writers require this.
  ///
  /// For async flush, see [flushAsync]
  Future<void> flushAsync() {
    throw UnimplementedError("This ISink does not implement `flushAsync`");
  }
}

abstract class IOpenable {
  /// Opens this writer. Not all writers require this.
  /// For async open, see [openAsync]
  void openSync();
}

abstract class IAsyncOpenable {
  /// Opens this writer asychronously Not all writers require this.
  /// For sync open, see [openSync]
  Future<void> openAsync();
}

abstract class IClosable {
  /// Closes this writer. Not all writers require this.
  /// For async close, see [closeAsync]
  void closeSync();
}

abstract class IAsyncClosable {
  /// Closes this writer. Not all writers requrie this.
  /// For sync close, see [closeSync]
  Future<void> closeAsync();
}
