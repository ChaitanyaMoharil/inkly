class Document {
  final String id;
  final String fileName;
  final String fileUrl;
  final DateTime uploadDate;
  final String fileType;
  final int fileSize;
  final String printCode;
  final String status; // 'pending', 'printed', 'downloaded'

  Document({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.uploadDate,
    required this.fileType,
    required this.fileSize,
    required this.printCode,
    this.status = 'pending',
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      printCode: json['printCode'] as String,
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate.toIso8601String(),
      'fileType': fileType,
      'fileSize': fileSize,
      'printCode': printCode,
      'status': status,
    };
  }
}
