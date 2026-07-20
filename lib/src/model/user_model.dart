import 'dart:convert';

class UserModel {
  final String id;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String email;
  final String? profilePic;
  final double? longitude;
  final double? latitude;
  final String? address;

  UserModel({
    required this.id,
    required this.createdAt,
    this.deletedAt,
    this.updatedAt,
    required this.isDeleted,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.email,
    this.profilePic,
    this.longitude,
    this.latitude,
    this.address
  });

  /// Factory constructor to create a PlayerModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id       : json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null
                  ? DateTime.parse(json['deleted_at'] as String) 
                  :  null,
      updatedAt: json['updated_at'] != null
                  ? DateTime.parse(json['updated_at'] as String) 
                  :  null,
      isDeleted  : json['is_deleted'] as bool,
      fullName   : json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      role       : json['role'] as String,
      email      : json['email'] as String,
      profilePic : json['profile_pic'] as String,
      longitude  : json['longitude'],
      latitude   : json['latitude'],
      address    : json['address'] as String,
    );
  }

  /// Converts the PlayerModel instance back into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'email': email,
    };
  }

  /// Helper method to parse a raw JSON string list directly into a List of PlayerModels
  static List<UserModel> fromJsonList(String str) =>
      List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x as Map<String, dynamic>)));

  /// Helper method to convert a List of PlayerModels directly to a JSON string
  static String toJsonList(List<UserModel> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}