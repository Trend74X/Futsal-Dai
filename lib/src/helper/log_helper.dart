

import 'dart:developer';

const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _redEnd = '\x1B[0m';
const _reset = '\x1B[0m';

const _helperFns = {'_currentFn', 'logSuccess', 'logError'};

String _currentFn() {
  final lines = StackTrace.current.toString().split('\n');
  for (var i = 0; i < lines.length; i++) {
    final match = RegExp(r'\b((?:\w+\.)?\w+)\s*\(').firstMatch(lines[i]);
    if (match != null) {
      final name = match.group(1)!.replaceAll(RegExp(r'^\w+\.'), '');
      if (!_helperFns.contains(name)) return name;
    }
  }
  return 'unknown';
}

/// Prints current function name in green when successful.
void logSuccess([String? message]) {
  log('$_green✓ ${message ?? _currentFn()}$_reset');
}

/// Prints current function name in red on failure.
void logError([String? message, Object? error]) {
  final suffix = error != null ? ' | $error' : '';
  log('$_red✗ ${message ?? _currentFn()}$suffix$_redEnd');
}