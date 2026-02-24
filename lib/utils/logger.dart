import 'package:flutter/foundation.dart';

enum LogLevel { debug, exception }

class Logger {
  static final Logger instance = Logger.internal();
  factory Logger() => instance;
  Logger.internal();

  void log({required String location, required String message, LogLevel level = LogLevel.debug}) {
    if (!kDebugMode && level != LogLevel.exception) return;

    print('$location :: $message');
    print('=' * 50);
  }
}
