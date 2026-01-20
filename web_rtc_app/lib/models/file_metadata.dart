/// Model for file metadata sent before file transfer
class FileMetadata {
  final String type;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String fileId;

  FileMetadata({
    required this.type,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.fileId,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      type: json['type'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      fileId: json['fileId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'fileId': fileId,
    };
  }

  /// Creates file metadata from file picker result
  factory FileMetadata.create({
    required String fileName,
    required int fileSize,
    required String mimeType,
  }) {
    return FileMetadata(
      type: 'file_metadata',
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      fileId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}

/// Model for file chunk sent during transfer
class FileChunk {
  final String type;
  final String fileId;
  final int chunkIndex;
  final int totalChunks;
  final List<int> data;

  FileChunk({
    required this.type,
    required this.fileId,
    required this.chunkIndex,
    required this.totalChunks,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'fileId': fileId,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'data': data,
    };
  }
}

/// Model for file transfer completion signal
class FileTransferComplete {
  final String type;
  final String fileId;

  FileTransferComplete({
    required this.type,
    required this.fileId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'fileId': fileId,
    };
  }

  factory FileTransferComplete.create(String fileId) {
    return FileTransferComplete(
      type: 'file_transfer_complete',
      fileId: fileId,
    );
  }
}

