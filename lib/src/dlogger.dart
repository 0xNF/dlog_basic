import 'package:dlogbasic/src/dlogger_base.dart';
import 'package:dlogbasic/src/isuppress.dart';
import 'package:dlogbasic/src/targets/basic_console_target.dart';
import 'package:dlogbasic/src/targets/i_target.dart';

import 'package:ilogger/ilogger.dart';

abstract class DLogger extends DLoggerBase implements ILogger, ISuppress {
  @override
  bool get isTraceEnabled => isEnabled(LogLevel.trace);
  @override
  bool get isDebugEnabled => isEnabled(LogLevel.debug);
  @override
  bool get isInfoEnabled => isEnabled(LogLevel.info);
  @override
  bool get isWarnEnabled => isEnabled(LogLevel.warn);
  @override
  bool get isErrorEnabled => isEnabled(LogLevel.error);
  @override
  bool get isFatalEnabled => isEnabled(LogLevel.fatal);

  /// Writes a diagnostic message at the [LogLevel.trace] levels
  @override
  void trace(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.debug] level
  @override
  void debug(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.info] level
  @override
  void info(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.warn] level
  @override
  void warn(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.error] level
  @override
  void error(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  /// Writes a diagnostic message at the [LogLevel.fatal] level
  @override
  void fatal(dynamic message, {Exception? exception, Map<String, dynamic>? eventProperties});

  // @override
  // void log(
  //   LogLevel level,
  //   dynamic message, {
  //   Map<String, dynamic>? eventProperties,
  //   Exception? exception,
  // }) {}

  /// Runs action.
  ///
  ///  If the action throws, the exception is logged at Error level. Exception is not propagated outside of this method.
  @override
  void swallow(Function action) {
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
  Future<void> swallowAsync(Function action) async {
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

  const DLogger({
    required super.name,
    super.targets = const <ITarget>[
      BasicConsoleTarget(),
    ],
  });
}
