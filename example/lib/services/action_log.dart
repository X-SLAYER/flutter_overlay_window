import 'package:flutter/foundation.dart';

enum LogLevel { info, success, error, incoming }

class LogEntry {
  LogEntry(this.title, this.message, this.level) : time = DateTime.now();

  final String title;
  final String message;
  final LogLevel level;
  final DateTime time;
}

/// Collects the result of every demo action so testers can see what each
/// plugin call returned without reading `adb logcat`.
class ActionLog extends ChangeNotifier {
  static const int _maxEntries = 100;

  final List<LogEntry> _entries = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);

  void add(String title, String message, [LogLevel level = LogLevel.info]) {
    _entries.insert(0, LogEntry(title, message, level));
    if (_entries.length > _maxEntries) _entries.removeLast();
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
