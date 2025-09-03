/// Domain entity representing a cached item
class CacheEntry {
  final String key;
  final dynamic data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, String>? headers;
  final String? etag;
  final int? statusCode;
  final String contentType;
  final int sizeInBytes;

  const CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.headers,
    this.etag,
    this.statusCode,
    this.contentType = 'application/json',
    required this.sizeInBytes,
  });

  /// Check if the cache entry is still valid
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if the cache entry is stale
  bool get isStale => !isValid;

  /// Age of the cache entry in milliseconds
  int get ageInMilliseconds =>
      DateTime.now().difference(createdAt).inMilliseconds;

  /// Age of the cache entry
  Duration get age => DateTime.now().difference(createdAt);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheEntry && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'CacheEntry(key: $key, isValid: $isValid, age: $age, size: $sizeInBytes bytes)';
  }

  /// Create a copy of this entry with updated values
  CacheEntry copyWith({
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
    return CacheEntry(
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
