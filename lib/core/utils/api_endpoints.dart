class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.106:8000/api';
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String googleLogin =
      '$baseUrl/auth/google/token'; // Endpoint لتسجيل الدخول عبر غوغل
  static const String verifyCode =
      '$baseUrl/verify-code'; // إضافة endpoint للتحقق من البريد الإلكتروني
}
