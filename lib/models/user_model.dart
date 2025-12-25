// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'phoneNumber': phoneNumber,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'],
    email: json['email'],
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    photoUrl: json['photoUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}