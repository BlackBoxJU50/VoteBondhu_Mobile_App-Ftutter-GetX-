import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String dob;
  final String area;
  final String ashon;
  final String? profileImageUrl;
  final String? bio;
  final DateTime createdAt;
  final String role;
  final String work;
  final String education;
  final int points;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.dob,
    required this.area,
    required this.ashon,
    this.profileImageUrl,
    this.bio,
    required this.createdAt,
    this.role = 'voter',
    this.points = 0,
    this.work = '',
    this.education = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      dob: map['dob'] ?? '',
      area: map['area'] ?? '',
      ashon: map['ashon'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: map['role'] ?? 'voter',
      points: map['points'] ?? 0,
      work: map['work'] ?? '',
      education: map['education'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'dob': dob,
      'area': area,
      'ashon': ashon,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'createdAt': FieldValue.serverTimestamp(),
      'role': role,
      'points': points,
      'work': work,
      'education': education,
    };
  }
}
