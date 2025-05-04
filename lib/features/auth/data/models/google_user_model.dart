
class GoogleUserModel {
  final String name;
  final String email;

  GoogleUserModel({required this.name, required this.email});

  factory GoogleUserModel.fromJson(Map<String, dynamic> json) {
    return GoogleUserModel(
      name: json['name'],
      email: json['email'],
    );
  }
}
