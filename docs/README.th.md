
# Easy Cache Manager (ภาษาไทย)

## คุณสมบัติ
- รองรับ LRU, TTL, และ custom eviction policy
- Analytics ปรับแต่งได้ (เช่น Firebase, Sentry)
- ใช้งานง่ายกับ Flutter, REST API, และ state management
- รองรับ Hive NoSQL, DI, และ Clean Architecture

## Integration Example
### การใช้งานกับ Flutter Widget
```dart
class CachedImageWidget extends StatelessWidget {
  final String url;
  final cacheManager = CacheManager(
    config: AdvancedCacheConfig.production(),
    storage: HiveCacheStorage(
      evictionPolicy: LRUEvictionPolicy(100),
      analytics: SimpleCacheAnalytics(),
    ),
  );

  CachedImageWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: cacheManager.getFile(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.file(snapshot.data!);
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

### การใช้งานกับ REST API
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(1000),
    analytics: SimpleCacheAnalytics(),
  ),
);

Future<Map<String, dynamic>> fetchUser(String id) async {
  final cached = await cacheManager.getJson('user_$id');
  if (cached != null) return cached;
  final response = await http.get(Uri.parse('https://api.example.com/user/$id'));
  final data = jsonDecode(response.body);
  await cacheManager.save('user_$id', data);
  return data;
}
```

### Analytics แบบกำหนดเอง
```dart
class MyAnalytics implements CacheAnalytics {
  @override
  void recordEvent(String event, Map<String, dynamic> details) {
    // ส่งข้อมูลไป Firebase, Sentry ฯลฯ
  }

  @override
  Map<String, dynamic> exportMetrics() => {/* ... */};
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(100),
    analytics: MyAnalytics(),
  ),
);
```

## Installation
1. เพิ่ม dependency ใน pubspec.yaml
2. รัน `flutter pub get`
3. ดูตัวอย่างใน README.md หรือ docs/README.th.md

## Lint Best Practices
- ใช้ const กับ Duration, String, List, Map ที่เป็นค่าคงที่
- ใช้ curly braces ใน if/for/while ทุกกรณี
- ใส่ comment อธิบาย logic ใน test และตัวอย่าง

## Comparison
- มี CLI harness สำหรับ benchmark และเปรียบเทียบกับ cache manager อื่น ๆ
- รองรับการ export metrics เป็น CSV/JSON

## ติดต่อ/สนับสนุน
- เปิด issue หรือ pull request ใน GitHub
- อีเมล: support@easycache.dev
