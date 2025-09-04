# 👶 คู่มือสำหรับมือใหม่ - เริ่มต้นใช้งาน Easy Cache Manager

> **🎯 เป้าหมาย**: ใช้งาน cache ได้ใน 5 นาที โดยไม่ต้องเข้าใจ Clean Architecture

## 🚀 เริ่มต้นแบบ Super Simple (แค่ 3 ขั้นตอน!)

### 1️⃣ ติดตั้ง Package

เพิ่มใน `pubspec.yaml`:

```yaml
dependencies:
  easy_cache_manager: ^1.0.0
```

รัน:

```bash
flutter pub get
```

### 2️⃣ Copy-Paste Code นี้

สร้างไฟล์ `lib/simple_cache.dart`:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

/// 😎 Simple Cache - ไม่ต้องคิดอะไรเลย!
class SimpleCache {
  static CacheManager? _cache;

  /// เรียกใช้ครั้งเดียวตอน app เริ่ม
  static Future<void> init() async {
    _cache = CacheManager(config: MinimalCacheConfig.auto());
  }

  /// เก็บข้อมูล
  static Future<void> save(String key, dynamic data) async {
    await _cache!.storeJson(key, data);
  }

  /// ดึงข้อมูล
  static Future<T?> get<T>(String key) async {
    return await _cache!.getJson(key);
  }

  /// เก็บรูปภาพ
  static Future<void> saveImage(String url) async {
    await _cache!.getBytes(url);
  }

  /// ดึงรูปภาพ
  static Future<List<int>?> getImage(String url) async {
    return await _cache!.getBytes(url);
  }

  /// ลบข้อมูล
  static Future<void> delete(String key) async {
    await _cache!.remove(key);
  }

  /// ลบทุกอย่าง
  static Future<void> clearAll() async {
    await _cache!.clear();
  }
}
```

### 3️⃣ ใช้งานในแอป

ในไฟล์ `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'simple_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่ม cache
  await SimpleCache.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? cachedData;

  @override
  void initState() {
    super.initState();
    loadCachedData();
  }

  Future<void> loadCachedData() async {
    // ดึงข้อมูลที่เก็บไว้
    final data = await SimpleCache.get<String>('my_data');
    setState(() {
      cachedData = data;
    });
  }

  Future<void> saveData() async {
    // เก็บข้อมูล
    await SimpleCache.save('my_data', 'Hello from Cache!');
    loadCachedData(); // รีเฟรช
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Cache Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cached Data:'),
            Text(cachedData ?? 'No data'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveData,
              child: Text('Save Data'),
            ),
            ElevatedButton(
              onPressed: () => SimpleCache.clearAll(),
              child: Text('Clear All'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🎉 เสร็จแล้ว! ใช้งานได้เลย

### ✨ ตัวอย่างการใช้งานจริง

#### 💾 Cache API Response

```dart
// เก็บข้อมูล user
Map<String, dynamic> userData = {
  'id': '123',
  'name': 'John Doe',
  'email': 'john@example.com'
};

await SimpleCache.save('user_123', userData);

// ดึงข้อมูล user
final user = await SimpleCache.get<Map<String, dynamic>>('user_123');
print(user?['name']); // John Doe
```

#### 🖼️ Cache Images

```dart
// เก็บรูปจาก URL
await SimpleCache.saveImage('https://example.com/avatar.jpg');

// ดึงรูปที่เก็บไว้
final imageBytes = await SimpleCache.getImage('https://example.com/avatar.jpg');

// ใช้กับ Image widget
if (imageBytes != null) {
  Image.memory(Uint8List.fromList(imageBytes));
}
```

#### 📝 Cache Form Data

```dart
// เก็บข้อมูล form ที่ผู้ใช้กรอก
Map<String, String> formData = {
  'firstName': 'John',
  'lastName': 'Doe',
  'phone': '123-456-7890'
};

await SimpleCache.save('draft_form', formData);

// ดึงข้อมูลมาใส่ form เมื่อเปิดแอปใหม่
final draft = await SimpleCache.get<Map<String, String>>('draft_form');
if (draft != null) {
  firstNameController.text = draft['firstName'] ?? '';
  lastNameController.text = draft['lastName'] ?? '';
  phoneController.text = draft['phone'] ?? '';
}
```

## 🔧 Troubleshooting - แก้ปัญหาเบื้องต้น

### ❌ Error: "CacheManager not initialized"

**สาเหตุ**: ลืมเรียก `SimpleCache.init()`

**วิธีแก้**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleCache.init(); // ← อย่าลืมบรรทัดนี้!
  runApp(MyApp());
}
```

### ❌ Error: "type 'Null' is not a subtype"

**สาเหตุ**: ข้อมูลที่ดึงมาไม่ตรงกับ type ที่คาดหวัง

**วิธีแก้**:

```dart
// ❌ ผิด
final data = await SimpleCache.get<String>('number_data'); // แต่เก็บไว้เป็น int

// ✅ ถูก
final data = await SimpleCache.get('number_data'); // ใช้ dynamic
// หรือ
final data = await SimpleCache.get<int>('number_data'); // ใช้ type ที่ถูก
```

### ❌ แอปช้าหรือค้าง

**สาเหตุ**: เก็บข้อมูลใหญ่เกินไป

**วิธีแก้**:

```dart
// ตรวจสอบขนาด cache
final stats = await _cache!.getStats();
print('Cache size: ${stats.totalSizeInBytes} bytes');

// ลบข้อมูลเก่า
await SimpleCache.clearAll();
```

## 🎓 พร้อมเรียนรู้มากขึ้น?

เมื่อคุณใช้งาน SimpleCache คล่องแล้ว ลองเรียนรู้เพิ่มเติม:

### 📚 ขั้นต่อไป

1. **[Configuration Guide](../config/)** - ปรับแต่ง cache ให้เหมาะกับแอป
2. **[Clean Architecture](../architecture/)** - เรียนรู้สถาปัตยกรรมที่แท้จริง
3. **[Advanced Features](../advanced/)** - Compression, Encryption, Eviction policies
4. **[Performance Optimization](../performance/)** - เพิ่มความเร็ว

### 🎮 แชลเลนจ์สำหรับมือใหม่

ลองทำ mini project เหล่านี้:

1. **📱 Todo App with Cache**: เก็บ todo list ใน cache
2. **🖼️ Image Gallery**: cache รูปจาก internet
3. **📰 News Reader**: cache ข่าวสารสำหรับอ่านออฟไลน์
4. **🛒 Shopping Cart**: เก็บสินค้าใน cart ใน cache

### 💬 ขอความช่วยเหลือ

- 🐛 **Bug Report**: [GitHub Issues](https://github.com/kidpech/easy_cache_manager/issues)
- 💭 **Question**: [GitHub Discussions](https://github.com/kidpech/easy_cache_manager/discussions)
- 📧 **Email**: support@easycachemanager.dev
- 💬 **Discord**: [Join our community](https://discord.gg/easy-cache-manager)

---

> 🎉 **ขอแสดงความยินดี!** คุณเรียนรู้การใช้ cache เบื้องต้นแล้ว
>
> อย่าลืม: **การ cache ที่ดี = แอปที่เร็วและประหยัด data** 📱⚡

## 🏆 เคล็ดลับมืออาชีพ

### ⚡ Performance Tips

```dart
// ✅ ดี: cache ข้อมูลที่ไม่เปลี่ยนบ่อย
await SimpleCache.save('app_config', config); // config ไม่เปลี่ยนบ่อย

// ❌ ไม่ดี: cache ข้อมูลที่เปลี่ยนตลอดเวลา
await SimpleCache.save('current_time', DateTime.now()); // เปลี่ยนทุกวินาที
```

### 🔑 Key Naming Convention

```dart
// ✅ ใช้ prefix แยกประเภท
await SimpleCache.save('user_123', userData);
await SimpleCache.save('image_avatar_123', imageData);
await SimpleCache.save('api_news_today', newsData);

// ❌ key ซ้ำกันได้
await SimpleCache.save('123', userData); // อาจซ้ำกับข้อมูลอื่น
```

### 🧹 Memory Management

```dart
// ตรวจสอบขนาด cache เป็นระยะ
Timer.periodic(Duration(hours: 1), (timer) async {
  final stats = await _cache!.getStats();
  if (stats.totalSizeInBytes > 50 * 1024 * 1024) { // > 50MB
    // ลบข้อมูลเก่า
    await SimpleCache.clearAll();
  }
});
```

---

_🎯 ตอนนี้คุณพร้อมใช้ cache แบบมืออาชีพแล้ว! ไปสร้างแอปเจ๋งๆ กันเถอะ 🚀_
