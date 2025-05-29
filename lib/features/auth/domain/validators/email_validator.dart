class EmailValidator {
  static bool isValid(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}