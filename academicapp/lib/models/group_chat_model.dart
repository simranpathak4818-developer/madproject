class GroupChatModel {
  final String id;
  final String name;
  final List<String> memberIds;
  final List<String> memberNames;
  final String createdBy;
  final DateTime createdAt;
  final String? description;

  GroupChatModel({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.memberNames,
    required this.createdBy,
    required this.createdAt,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      memberNames: List<String>.from(map['memberNames'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      description: map['description'],
    );
  }
}