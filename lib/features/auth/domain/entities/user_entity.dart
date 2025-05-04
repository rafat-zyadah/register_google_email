
class User {
  final int id;
  final String name;
  final String email;
  final int verificationCode;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.verificationCode,
  });
}
