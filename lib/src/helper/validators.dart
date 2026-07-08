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

/// validate min-max length
String? validateMinMaxLength({required String string, int minLegth = 1, int maxLength = 10}) {
  return (string.length < minLegth || string.length > maxLength)
    ? "Must be between $minLegth and $maxLength characters"
    : null;
}

// String? validatePassword({
//   required String string,
//   required int minLength,
//   required int maxLength,
// }) {
//   RegExp allowedCharacters = RegExp(r'^[!@#$%^&*()_+~`A-Za-z0-9]+$');
//   RegExp containsSpace = RegExp(r'\s');
//   RegExp hasUpperCase = RegExp(r'[A-Z]');
//   RegExp hasLowerCase = RegExp(r'[a-z]');
//   RegExp hasDigit = RegExp(r'\d');
//   // RegExp invalidCharacter = RegExp(r'[^!@#$%^&*()_+~A-Za-z0-9]');

//   if (string.isEmpty) {
//     return "emptyError".tr;
//   } else if (string.length < minLength) {
//     return "passwordIs".tr+minLength.toString()+'atLeast1Char'.tr;
//   } else if (string.length > maxLength) {
//     return "passwordIs".tr+maxLength.toString()+'atMost15Char'.tr;
//   } else if (containsSpace.hasMatch(string)) {
//     return "spacesNotAllowed".tr;
//   } else if (!allowedCharacters.hasMatch(string)) {
//     return "invalidCharacter".tr;
//   } else if (!hasUpperCase.hasMatch(string)) {
//     return "atLeast1Uppercase".tr; // At least one uppercase letter required
//   } else if (!hasLowerCase.hasMatch(string)) {
//     return "atLeast1Lowercase".tr; // At least one lowercase letter required
//   } else if (!hasDigit.hasMatch(string)) {
//     return "atLeast1Digit".tr; // At least one digit required
//   }
//   // else if(!invalidCharacter.hasMatch(string)){
//   //   return "「半角英数字または記号を入力してください。」"; // EN: "Please enter alphanumeric characters or symbols."
//   // }
//   else {
//     return null;
//   }
// }