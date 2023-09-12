A basic logging solution for Dart modeled after NLog, which uses implementations from [Dart ILogger](https://github.com/0xnf/dlog_basic).


# Usage

This implememtation comes with everthing needed to create your own loggers, and in fact you are encouraged to create your own for specific purposes that you encounter. However for the sake of usability, this package comes with two default implementations ready to go out of the box:

## Basic Logger

```dart
final ILogger logger = BasicLogger(name: 'YourLogger');
logger.info('some message') // [09-12-2013T19:35:21+9:00] some message ||
```
The basic logger uses the `ConsoleTarget` target to print to the stdout console. 

## Null Logger
```dart
final ILogger logger = NullLogger(name: 'YourNullLogger');
logger.info('some message'); // nothing will happen, this is a NOP
```


## Log Levels

The following log levels are available. They're listed in asencing order of severity:

- trace
- debug
- info
- warn
- error
- fatal
- off

Off is a special level which indicates that it shouldn't be logged. 

# Loggers, Targets, Formatters, Sinks,


## Heirarchy
The hierarchy of loggers is like this:

                      [ Logger ]
                           |
                           |
                    [ Target {1,n} ]
                           |
                           |
                       [ Sink ]

Loggers have n-many targets, and each target has 1 sink.


## Loggers

A logger is an object that has methods for writing messages at various log levels. For example:

```dart
logger.warn('some warning message');
logger.fatal('an exceptionally bad message');
```

### Exceptions and Event Parameters

Logging methods can take optional exceptions and eventParameters. These get their own special consideration when printing out logging statements:

```dart
try {
  throw Exception("Didn't work");
} on Exception catch (e) {
   logger.error('Failed to push the thing', exception: e);
}
```
If the ConsoleTarget is configured for this logger, which it is by default, the stdout will look like this:
> [9-12-203T19:54:32+9:00] [ERROR] Failed to push the thing |Exception("Didn't work")|

Logging methods can also take an `eventParameters` field which is an optional JSON Object of unspecified schema which can be used to pass extra data along:

```dart
void serveFile(String path) {
    logger.info('Received request for file', eventParameters: {'path': path});
}
serveFile("addresses.txt");
```
Again using the ConsoleTarget, this will print:
> [9-12-203T19:54:32+9:00] [INFO] Received request for file ||{'path': 'addresses.txt'}


### Enabled Levels
Loggers can choose whether to enable to log or ignore events of certain levels.

You can check the status of each log level by the specific getters:

```dart
logger.isTraceEnabled; // true or false
```

or by sending a specific log level:

```dart
logLevel = LogLevel.trace;
logger.isLogLevelEnabled(logLevel); // true or false
```

Depending on the implementation of the logger you are using, you may be able to change this at runtime or not.

## Targets

### Premade Targets
The following targets are included by default:
- BasicConsoleTarget
- BasicFileTarget

The BasicConsoleTarget writes log events to `stdout`, and the `BasicFileTarget` , when given a path to a file (existing or not, doesn't matter), will write its contents to the file. 

With respect to the file target, log rotation is [included](#log-rotation) in this package.

### Overview

Targets are the where & when of writing log file. Targets contain three methods:

```dart
class ITarget {

  /// Formats the log event and writes to the sink asychronously. Not required.
  ///
  /// For async, see [writeAsync]
  void writeSync(LogEvent logEvent);

  /// Formats the log event and writes to the sink asychronously. Required.
  ///
  /// For sync, see [writeSync]
  Future<void> writeAsync(LogEvent logEvent);

  /// Whether this log event should be written to this logger
  bool shouldWrite(LogEvent logEvent);
}
```

It is up to each target how to implement these methods, but just be aware that a target can choose to ignore a log message as it sees fit with the `shouldWrite()` method.

That covers the "when" but the "where" is determined by the `writeSync()` and `writeAsync()` methods. Targets are constructed with two additional fields:

```dart
final IFormatter formatter;
final ISink sink;
```

which the write methods should use to format and send off the actual bitwise log message. 

Here is the implementation for the  writeSync `BasicConsoleTarget`:

```dart
@override
void writeSync(LogEvent logEvent) {
    final msg = formatter.format(logEvent);
    sink.writeAsync(msg);
}
```

notice that it uses the `formatter` to format the incoming log event, which rfeturns the full stringified log message as it will be written out in memory, then it sends the message to the `sink`.

The sink takes care of the "how" to write, the formatter takes care of the "what", and the target takes care of orchestrating these things together.

## Formatters
A formatter is an object owned by a Target that determines exactly how to produce a String from a log event. There are two formatters included by default:

- `BasicFormatter`
- `JsonFormatter`
- `JsonLinesFormatter`

The `BasicFormatter` produces strings in the following format:
>[$DateTime] [$LogLevel] [LoggerName] $message |$exception||$eventProperties

The `JsonFormatter` produces strings in the following format:

```TypeScript
{
  'Timestamp': number,
  'Level': string,
  'Name': string,
  'Message': string,
  'Exception': string?,
  'EventProperties': JsonObject?
}
```

The `JsonLinesFormatter` produces strings in the following format:

```TypeScript
{'Timestamp': number,'Level': string,'Name': string,'Message': string,'Exception': string?,'EventProperties': JsonObject?}
```

The difference between jsona nd json lines is that JsonLines uses the [JSONLines Format](https://jsonlines.org/), which is a good format for streaming log data.

### Variables

The includes formatters, and therefore the default included set of sinks and targets, all process their Log Event messages for the eventParameters and perform substitution where appropriate.

For example:

```dart
logger.info('Received request for file at path {path}', eventParameters: {'path': 'addresses.txt'});
```

This will look at the parameters, if any, supplied to `eventParameters`, and then look for any matching keys in curly braces in the original message and replace the curly braces with the value found in the eventParameters. This will produce a final message like this:

> [9-12-203T19:54:32+9:00] [INFO] Received request for file at path addresses.txt ||{'path': 'addresses.txt'}   

This functionality can be escaped with backslashes:
```dart
logger.info('Received request for file at path \{path\}', eventParameters: {'path': 'addresses.txt'});
```
> [9-12-203T19:54:32+9:00] [INFO] Received request for file at path {path} ||{'path': 'addresses.txt'}   


## Sinks

Sinks are an actual end-point for writing a log message. This could include a file, a stdout/stderr pipe, a network connection, or a database connection.

### Premade Sinks
The following sinks are included by default in this package:

- `BasicConsoleSink`
- `BasicFileSink`

The `BasicConsoleSink` takes care of actually writing to `stdout`, and the `BasicFileSink` takes care of the much more complicated task of appending to a file. The file sink also has the ability to take a [FileRotation](#log-rotation) object to help it roll over files when appropriate.


### Overview

Sinks really only have two methods that are interesting:

```dart
  /// Writes the final message to the sink. Not all writers require this.
  /// For async write, see [writeAsync]
  void writeSync(String formattedMessage);

  /// Flushes any pending changes to this sink. Not all writers require this.
  ///
  /// For async flush, see [flushAsync]
  void flushSync();
```

A call to `writeSync` may or may not actually immediately produce a write event to the underlying final location. Instead, it is up to the sink when it is most appropriate to perform those writes. That is, a sink may batch up writes in memory before sending them onward. If the caller of the library wishes however, they can force writes with thw `flush` family of methods.

## Log Rotation

This package includes a rudimentary system for performing File Rotations when using the `FileTarget`. Of course, you are free to use this in your own loggers as well, but it is included fully packaged for your convenience.

```dart
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
}
```


# Structured Logging
Using the included `JsonFormatter` or `JsonLinesFormatter` you can achieve structured logging. 


# Future Development
Targets will be able to be defined by a Json File, which can be modified from outside the program. This fill will be read at runtime and can modify behavior of the logging system ad-hoc.

Loggers will be able to be reconfigrued at runtime, so that changes to their targets can be reloaded from within a running program.


# Contributing
If you want to contribute to this repository, consider looking at the underlying [Dart ILogger](https://github.com/0xnf/dlog_basic), or this repository at https://github.com/0xnf/dlog_basic