// ============= lib/models/user.dart =============
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String memberSince;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '03213114620',
    this.memberSince = '24/12/2025',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'memberSince': memberSince,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      memberSince: map['memberSince'],
    );
  }
}
