class MemoryModel {
  final int? id;
  final DateTime timestamp;
  final String content;
  final bool isSynced;

  MemoryModel({
    this.id,
    required this.timestamp,
    required this.content,
    this.isSynced = false,
  });

  factory MemoryModel.fromMap(Map<String, dynamic> map) {
    return MemoryModel(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      content: map['content'],
      isSynced: map['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'content': content,
      'isSynced': isSynced ? 1 : 0,
    };
  }
}
