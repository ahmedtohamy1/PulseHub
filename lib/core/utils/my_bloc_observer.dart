import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _log('CREATE', bloc.runtimeType);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _log('CHANGE', bloc.runtimeType, change: change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _log('ERROR', bloc.runtimeType, error: error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _log('CLOSE', bloc.runtimeType);
  }

  // Private method for logging with enhanced formatting for readability
  void _log(String event, Type blocType, {Object? error, Change? change}) {
    if (kDebugMode) {
      final blocName = blocType.toString().split('.').last;

      // Check for keywords in event or change to apply color formatting
      final isSuccess = event.toLowerCase().contains('success') ||
          (change?.nextState.toString().toLowerCase().contains('success') ??
              false);
      final isError = event.toLowerCase().contains('error') ||
          event.toLowerCase().contains('fail') ||
          event.toLowerCase().contains('failed') ||
          (change?.nextState.toString().toLowerCase().contains('error') ??
              false) ||
          (change?.nextState.toString().toLowerCase().contains('fail') ??
              false) ||
          (change?.nextState.toString().toLowerCase().contains('failed') ??
              false);

      // Use green color for success states, red and bold for error or fail states
      final logBuffer = StringBuffer();
      if (isSuccess) {
        logBuffer.write('\x1B[32m'); // Green for success
      } else if (isError) {
        logBuffer.write('\x1B[1;31m'); // Red and bold for error/fail
      } else {
        logBuffer.write('\x1B[33m'); // Yellow for other events
      }

      logBuffer
          .write('[$event] [$blocName]\x1B[0m'); // Reset color after bloc name

      if (error != null) {
        logBuffer.write(' \x1B[1;31m- Error: ${_formatError(error)}\x1B[0m');
      }

      if (change != null) {
        logBuffer
          ..write('\n')
          ..write('    \x1B[34m- Change: $change\x1B[0m'); // Blue for changes
      }

      print(logBuffer.toString());
    }
  }

  // Format error object to be more user-friendly
  String _formatError(Object error) {
    if (error is Error) {
      return error.toString(); // For general Dart errors
    } else if (error is Exception) {
      return error.toString(); // For exceptions
    } else {
      return 'Unexpected error type: ${error.runtimeType}';
    }
  }
}
