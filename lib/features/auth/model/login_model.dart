class LoginModel {
  final String email; // ✅ Changed from login to email
  final String password;
  final String? message; // Optional for API responses
  final Map<String, dynamic>? user; // Optional for API responses
  final String? token; // Optional for API responses

  LoginModel({
    required this.email,
    required this.password,
    this.message,
    this.user,
    this.token,
  });

  /// ✅ Convert Model to JSON for Login Requests
  Map<String, dynamic> toJson() {
    return {
      'email': email, // ✅ Changed from 'login' to 'email'
      'password': password,
    };
  }

  /// ✅ Factory Constructor to Map API Response
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'] ?? "Login successful",
      user: json['user'] ?? {},
      token: json['token'] ?? "",
      email: '', // Not required in response mapping
      password: '', // Not required in response mapping
    );
  }
}
