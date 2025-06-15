class AppRegex {


  static bool isEmailValid(String email) {
    return RegExp(r"^[\w-\.]+@([a-zA-Z]+\.)+[a-zA-Z]{2,}$").hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    return RegExp(
        r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
    ).hasMatch(password);
  }

  static bool isPhoneValid(String phoneNumber) {
    return RegExp(
        r"^(?:\+20)?01[0125]\d{8}$"
    ).hasMatch(phoneNumber);
  }

  static bool hasLowerCase(String password) {
    return RegExp(r"^(?=.*[a-z])").hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r"^(?=.*[A-Z])").hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r"^(?=.*\d)").hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r"^(?=.*[@$!%*?&])").hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r"^.{8,}$").hasMatch(password);
  }

}
