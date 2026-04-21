class MaterialModel {
  final String id;
  final String title;
  final String description;
  final String branch;
  final String semester;
  final String section;
  final String fileUrl;
  final String fileName;
  final String uploadedBy;
  final String uploaderName;
  final DateTime uploadedAt;
  final int downloadCount;

  MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.branch,
    required this.semester,
    required this.section,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    required this.uploaderName,
    required this.uploadedAt,
    this.downloadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'branch': branch,
      'semester': semester,
      'section': section,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'downloadCount': downloadCount,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? '',
      section: map['section'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      uploadedAt: DateTime.parse(map['uploadedAt'] ?? DateTime.now().toIso8601String()),
      downloadCount: map['downloadCount'] ?? 0,
    );
  }
}