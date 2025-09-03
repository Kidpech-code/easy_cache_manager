import 'package:hive/hive.dart';
import '../../domain/entities/cache_entry.dart';

part 'hive_cache_entry.g.dart';

@HiveType(typeId: 0)
class HiveCacheEntry extends HiveObject {
  @HiveField(0)
  @override
  String key;

  @HiveField(1)
  dynamic data;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime? expiresAt;

  @HiveField(4)
  Map<String, String>? headers;

  @HiveField(5)
  String? etag;

  @HiveField(6)
  int? statusCode;

  @HiveField(7)
  String contentType;

  @HiveField(8)
  int sizeInBytes;

  @HiveField(9)
  bool isBinary;

  @HiveField(10)
  String? filePath; // For binary files

  HiveCacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.headers,
    this.etag,
    this.statusCode,
    this.contentType = 'application/json',
    required this.sizeInBytes,
    this.isBinary = false,
    this.filePath,
  });

  /// Check if entry is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get age of entry
  Duration get age => DateTime.now().difference(createdAt);

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

  /// Create from domain entity
  static HiveCacheEntry fromEntity(CacheEntry entity) {
    return HiveCacheEntry(
      key: entity.key,
      data: entity.data,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
      headers: entity.headers,
      etag: entity.etag,
      statusCode: entity.statusCode,
      contentType: entity.contentType,
      sizeInBytes: entity.sizeInBytes,
      isBinary:
          entity.data is! String && entity.data is! Map && entity.data is! List,
    );
  }

  @override
  String toString() {
    return 'HiveCacheEntry(key: $key, size: ${sizeInBytes}B, created: $createdAt, expires: $expiresAt)';
  }
}
