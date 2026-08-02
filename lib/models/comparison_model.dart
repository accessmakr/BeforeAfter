import 'dart:convert';
import 'dart:typed_data';

/// Represents a single before/after photo comparison.
/// All fields are non-nullable with sensible defaults for null safety.
class ComparisonModel {
  final String id;
  final String title;
  final String beforePath;
  final String afterPath;
  final Uint8List? beforeThumbnail;
  final Uint8List? afterThumbnail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComparisonModel({
    required this.id,
    required this.title,
    required this.beforePath,
    required this.afterPath,
    this.beforeThumbnail,
    this.afterThumbnail,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new comparison with generated ID and current timestamps.
  factory ComparisonModel.create({
    required String title,
    required String beforePath,
    required String afterPath,
    Uint8List? beforeThumbnail,
    Uint8List? afterThumbnail,
  }) {
    final now = DateTime.now();
    return ComparisonModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? 'Untitled' : title,
      beforePath: beforePath,
      afterPath: afterPath,
      beforeThumbnail: beforeThumbnail,
      afterThumbnail: afterThumbnail,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Returns true if both image paths are non-empty and exist.
  bool get isValid => 
    beforePath.isNotEmpty && 
    afterPath.isNotEmpty;

  ComparisonModel copyWith({
    String? title,
    String? beforePath,
    String? afterPath,
    Uint8List? beforeThumbnail,
    Uint8List? afterThumbnail,
    DateTime? updatedAt,
  }) {
    return ComparisonModel(
      id: id,
      title: title ?? this.title,
      beforePath: beforePath ?? this.beforePath,
      afterPath: afterPath ?? this.afterPath,
      beforeThumbnail: beforeThumbnail ?? this.beforeThumbnail,
      afterThumbnail: afterThumbnail ?? this.afterThumbnail,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'beforePath': beforePath,
      'afterPath': afterPath,
      'beforeThumbnail': beforeThumbnail != null ? base64Encode(beforeThumbnail!) : null,
      'afterThumbnail': afterThumbnail != null ? base64Encode(afterThumbnail!) : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ComparisonModel.fromJson(Map<String, dynamic> json) {
    return ComparisonModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled',
      beforePath: json['beforePath'] as String,
      afterPath: json['afterPath'] as String,
      beforeThumbnail: json['beforeThumbnail'] != null 
        ? base64Decode(json['beforeThumbnail'] as String) 
        : null,
      afterThumbnail: json['afterThumbnail'] != null 
        ? base64Decode(json['afterThumbnail'] as String) 
        : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() => 'ComparisonModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ComparisonModel &&
    runtimeType == other.runtimeType &&
    id == other.id;

  @override
  int get hashCode => id.hashCode;
}
