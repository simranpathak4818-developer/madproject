class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String branch;
  final String semester;
  final String section;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.branch,
    required this.semester,
    required this.section,
    this.profileImageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'branch': branch,
      'semester': semester,
      'section': section,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? branch,
    String? semester,
    String? section,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}