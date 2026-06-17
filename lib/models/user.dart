class User {
  final String id;
  final String name;
  final String email;
  final String password; // Untuk mock, biarkan plain text
  final String role; // 'traveler' atau 'organizer'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
