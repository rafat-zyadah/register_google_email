class PasswordValidator {
  static bool isValid(String password) {
    return password.trim().length >= 8;
  }
}
  