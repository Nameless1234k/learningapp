class AdminLessonModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final int subjectDisplayOrder;
  final String? documentId;
  final String? fileName;
  final String? filePath;
  final double? fileSizeMb;
  final int lessonNo;
  final String title;
  final String createdAt;

  AdminLessonModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    this.subjectDisplayOrder = 0,
    this.documentId,
    this.fileName,
    this.filePath,
    this.fileSizeMb,
    required this.lessonNo,
    required this.title,
    required this.createdAt,
  });

  factory AdminLessonModel.fromJson(Map<String, dynamic> json) {
    return AdminLessonModel(
      id: json['id']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString() ?? '',
      subjectDisplayOrder: json['subjectDisplayOrder'] is int
          ? json['subjectDisplayOrder']
          : int.tryParse(json['subjectDisplayOrder']?.toString() ?? '0') ?? 0,
      documentId: json['documentId']?.toString(),
      fileName: json['fileName']?.toString(),
      filePath: json['filePath']?.toString(),
      fileSizeMb: json['fileSizeMb'] != null ? (json['fileSizeMb'] as num).toDouble() : null,
      lessonNo: json['lessonNo'] is int ? json['lessonNo'] : int.tryParse(json['lessonNo']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
