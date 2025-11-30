import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Logger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      dev.log('🐛 $message', name: 'TODAY_APP', error: error, stackTrace: stackTrace);
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      dev.log('ℹ️ $message', name: 'TODAY_APP');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    dev.log('🚨 $message', name: 'TODAY_APP', error: error, stackTrace: stackTrace);
    // TODO: Send to Sentry in production
  }
}
