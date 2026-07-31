import 'package:flutter/material.dart';

class DaySchedule {
  String? id;
  int? dayOfWeek;
  String label;
  bool isEnabled;
  TimeOfDay startTime;
  TimeOfDay endTime;

  DaySchedule({
    this.id,
    required this.dayOfWeek,
    required this.label,
    this.isEnabled = true,
    this.startTime = const TimeOfDay(hour: 6, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 0),
  });

  // Convert TimeOfDay to database "HH:mm:ss" string
  static String _timeToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Map<String, dynamic> toMap(int venueId) {
    return {
      'venue_id': venueId,
      'day_of_week': dayOfWeek,
      'open_time': _timeToString(startTime),
      'close_time': _timeToString(endTime),
      'is_closed': !isEnabled,
      'is_peak': false,
    };
  }
}