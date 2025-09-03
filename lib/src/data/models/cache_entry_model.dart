import 'dart:convert';
import '../../domain/entities/cache_entry.dart';

/// Data model for cache entry that can be serialized/deserialized
class CacheEntryModel extends CacheEntry {
  const CacheEntryModel({
    required super.key,
    required super.data,
    required super.createdAt,
    super.expiresAt,
    super.headers,
    super.etag,
    super.statusCode,
    super.contentType,
    required super.sizeInBytes,
  });

  /// Create model from domain entity
  factory CacheEntryModel.fromEntity(CacheEntry entity) {
    return CacheEntryModel(
      key: entity.key,
      data: entity.data,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      headers: entity.headers,
      etag: entity.etag,
      statusCode: entity.statusCode,
      contentType: entity.contentType,
      sizeInBytes: entity.sizeInBytes,
    );
  }

  /// Create model from JSON
  factory CacheEntryModel.fromJson(Map<String, dynamic> json) {
    return CacheEntryModel(
      key: json['key'] as String,
      data: json['data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      expiresAt: json['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int)
          : null,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      etag: json['etag'] as String?,
      statusCode: json['status_code'] as int?,
      contentType: json['content_type'] as String? ?? 'application/json',
      sizeInBytes: json['size_in_bytes'] as int,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'created_at': createdAt.millisecondsSinceEpoch,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
      'headers': headers,
      'etag': etag,
      'status_code': statusCode,
      'content_type': contentType,
      'size_in_bytes': sizeInBytes,
    };
  }

  /// Convert model to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create model from JSON string
  factory CacheEntryModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return CacheEntryModel.fromJson(json);
  }

  /// Convert to domain entity
  CacheEntry toEntity() {
    return CacheEntry(
      key: key,
      data: data,
      createdAt: createdAt,
      expiresAt: expiresAt,
      headers: headers,
      etag: etag,
      statusCode: statusCode,
      contentType: contentType,
      sizeInBytes: sizeInBytes,
    );
  }

  @override
  CacheEntryModel copyWith({
    String? key,
    dynamic data,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, String>? headers,
    String? etag,
    int? statusCode,
    String? contentType,
    int? sizeInBytes,
  }) {
    return CacheEntryModel(
      key: key ?? this.key,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      headers: headers ?? this.headers,
      etag: etag ?? this.etag,
      statusCode: statusCode ?? this.statusCode,
      contentType: contentType ?? this.contentType,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
    );
  }
}
