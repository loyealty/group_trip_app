class AppUser {
  final int id;
  final String email;
  final String name;
  final String createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
