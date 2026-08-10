class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String createdBy;
  final List<GroupMemberModel> groupMembers;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.createdBy,
    required this.groupMembers,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id          : json['id'] ?? '',
      name        : json['name'] ?? '',
      description : json['description'],
      image       : json['image'],
      createdBy   : json['created_by'] ?? '',
      groupMembers: (json['group_members'] as List<dynamic>?)
              ?.map((item) => GroupMemberModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'created_by': createdBy,
      'group_members': groupMembers.map((e) => e.toJson()).toList(),
    };
  }
}

class GroupMemberModel {
  final String userId;
  final String status;
  final UserModel? user;
  final String role;

  GroupMemberModel({
    required this.userId,
    required this.status,
    this.user,
    required this.role,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['user_id'] ?? '',
      status: json['status'] ?? 'pending',
      role  : json['role'],
      user  : json['Users'] != null ? UserModel.fromJson(json['Users']): null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status' : status,
      'role'   : role,
      'Users'  : user?.toJson(),
    };
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String? profilePic;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.profilePic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id        : json['id'] ?? '',
      fullName  : json['full_name'] ?? '',
      username  : json['username'] ?? '',
      profilePic: json['profile_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id'         : id,
      'full_name'  : fullName,
      'username'   : username,
      'profile_pic': profilePic,
    };
  }
}