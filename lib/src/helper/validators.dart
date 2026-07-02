/// email validator
String? validateEmail({required String string}) {
  String regex = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  if (string.trim().isEmpty) return "Required";
  if (!validRegexExp(regex, string.trim())) {
    return "Invalid email address";
  } else {
    return null;
  }
}

/// validate regex for the string
bool validRegexExp(String regex, String string) {
  return RegExp(regex).hasMatch(string);
}

/// validate empty string
String? validateIsEmpty({required String string}) {
  return string.isEmpty 
  ? "Cannot be empty" 
  : null;
}