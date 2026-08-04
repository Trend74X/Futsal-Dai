import 'package:intl/intl.dart';

String getRelativeDate(String dateString) {
  // Parse the incoming string (e.g. '2026-08-08')
  DateTime parsedDate = DateTime.parse(dateString);
  
  // Get current date
  DateTime now = DateTime.now();
  
  // Strip time for accurate day comparison
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime tomorrow = today.add(const Duration(days: 1));
  DateTime targetDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

  if (targetDate == today) {
    return 'TODAY';
  } else if (targetDate == tomorrow) {
    return 'TOMORROW';
  } else {
    // return DateFormat('MMM d, yyyy').format(parsedDate); 
    return DateFormat('MMM d').format(parsedDate); 
  }
}