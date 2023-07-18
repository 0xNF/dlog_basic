import 'package:dart_ilogger/src/ilogger_base.dart';
import 'package:dart_ilogger/src/isuppress.dart';
import 'package:dart_ilogger/src/log_level.dart';
import 'package:dart_ilogger/src/targets/basic_console_target.dart';
import 'package:dart_ilogger/src/targets/i_target.dart';

abstract class ILogger extends ILoggerBase implements ISuppress {
  bool get isTraceEnabled => isEnabled(LogLevel.trace);
  bool get isDebugEnabled => isEnabled(LogLevel.debug);
  bool get isInfoEnabled => isEnabled(LogLevel.info);
  bool get isWarnEnabled => isEnabled(LogLevel.warn);
  bool get isErrorEnabled => isEnabled(LogLevel.error);
  bool get isFatalEnabled => isEnabled(LogLevel.fatal);

  /// Writes a diagnostic message at the [LogLevel.trace] levels
  void trace(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.debug] level
  void debug(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.info] level
  void info(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.warn] level
  void warn(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.error] level
  void error(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.fatal] level
  void fatal(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Runs action.
  ///
  ///  If the action throws, the exception is logged at Error level. Exception is not propagated outside of this method.
  @override
  void swallow(Function() action) {
    try {
      action();
    } on Exception catch (e) {
      error("swallow: failed to run action", exception: e);
    }
  }

  /// Runs the provided function and returns its result.
  ///
  /// If exception is thrown, it is logged at Error level.  Exception is not propagated outside of this method.
  ///
  /// Fallback value is returned instead.
  @override
  T? swallowResult<T>(T? Function() action, [T? fallbackValue]) {
    try {
      return action();
    } on Exception catch (e) {
      error("swallowResult: failed to run action", exception: e);
      return fallbackValue;
    }
  }

  /// Runs async action.
  ///
  /// If the action throws, the exception is logged at Error level. Exception is not propagated outside of this method.
  @override
  Future<void> swallowAsync(Function() action) async {
    try {
      await action();
    } on Exception catch (e) {
      error("swallowAsync: failed to run action", exception: e);
    }
  }

  /// Runs the provided async function and returns its result.
  ///
  /// If exception is thrown, it is logged at Error level.  Exception is not propagated outside of this method.
  ///
  /// Fallback value is returned instead.
  @override
  Future<T?> swallowResultAsync<T>(Future<T?> Function() action, T? fallbackValue) async {
    try {
      T? res = await action();
      return res;
    } on Exception catch (e) {
      error("swallowResultAsync: failed to run action", exception: e);
      return fallbackValue;
    }
  }

  const ILogger({
    required super.name,
    super.targets = const <ITarget>[
      BasicConsoleTarget(),
    ],
  });
}
