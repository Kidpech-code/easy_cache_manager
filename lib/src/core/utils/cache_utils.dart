import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility functions for caching operations
class CacheUtils {
  /// Generate a cache key from URL and optional parameters
  static String generateCacheKey(String url,
      {Map<String, String>? headers,
      Map<String, dynamic>? queryParams,
      String? prefix}) {
    final buffer = StringBuffer();

    if (prefix != null) {
      buffer.write('${prefix}_');
    }

    buffer.write(url);

    // Add query parameters to key
    if (queryParams != null && queryParams.isNotEmpty) {
      final sortedParams = queryParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final param in sortedParams) {
        buffer.write('_${param.key}=${param.value}');
      }
    }

    // Add relevant headers to key
    if (headers != null) {
      final relevantHeaders = [
        'authorization',
        'user-agent',
        'accept-language'
      ];
      for (final headerName in relevantHeaders) {
        final value = headers[headerName] ?? headers[headerName.toLowerCase()];
        if (value != null) {
          buffer.write('_$headerName=$value');
        }
      }
    }

    // Generate SHA-256 hash for long keys
    final keyString = buffer.toString();
    if (keyString.length > 250) {
      final bytes = utf8.encode(keyString);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    return keyString;
  }

  /// Calculate estimated size of data in bytes
  static int calculateDataSize(dynamic data) {
    if (data == null) return 0;

    if (data is String) {
      return utf8.encode(data).length;
    }

    if (data is List<int>) {
      return data.length;
    }

    if (data is Map || data is List) {
      try {
        final jsonString = jsonEncode(data);
        return utf8.encode(jsonString).length;
      } catch (e) {
        // Fallback to string length estimation
        return data.toString().length;
      }
    }

    return data.toString().length;
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(2)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(2)} KB';
    } else {
      return '$bytes B';
    }
  }

  /// Format duration to human readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ${duration.inDays == 1 ? 'day' : 'days'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ${duration.inHours == 1 ? 'hour' : 'hours'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} ${duration.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds} ${duration.inSeconds == 1 ? 'second' : 'seconds'}';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }

  /// Check if a URL is a valid HTTP/HTTPS URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }

  /// Extract file extension from URL
  static String? getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDotIndex = path.lastIndexOf('.');
      if (lastDotIndex != -1 && lastDotIndex < path.length - 1) {
        return path.substring(lastDotIndex + 1).toLowerCase();
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Infer MIME type from URL or file extension
  static String inferMimeType(String url) {
    final extension = getFileExtension(url);
    if (extension == null) return 'application/octet-stream';

    switch (extension) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'bmp':
        return 'image/bmp';
      case 'ico':
        return 'image/x-icon';

      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      // Text
      case 'txt':
        return 'text/plain';
      case 'html':
      case 'htm':
        return 'text/html';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      case 'csv':
        return 'text/csv';

      // Archives
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      case 'tar':
        return 'application/x-tar';
      case 'gz':
        return 'application/gzip';

      // Audio/Video
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';

      default:
        return 'application/octet-stream';
    }
  }

  /// Clean invalid characters from filename
  static String sanitizeFilename(String filename) {
    // Replace invalid characters with underscore
    return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Convert milliseconds since epoch to DateTime
  static DateTime millisecondsToDateTime(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Convert DateTime to milliseconds since epoch
  static int dateTimeToMilliseconds(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }
}
