# 👶 **Easy Cache Manager - คู่มือเริ่มต้นสำหรับมือใหม่**

> 🎯 **เป้าหมาย**: ให้คุณสามารถใช้งาน cache ได้ภายใน 5 นาที โดยไม่ต้องเข้าใจ architecture ที่ซับซ้อน

## 🚀 **ตัวเลือกสำหรับผู้เริ่มต้น: เลือกแบบที่เหมาะกับคุณ**

### **วิธีที่ 1: EasyCacheManager.auto() (แนะนำ!)**

เหมาะกับ: **ทุกคน** - ระบบจะเลือกการตั้งค่าที่เหมาะสมให้อัตโนมัติ

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

// ใช้งานได้เลย - ไม่ต้องตั้งค่าอะไร!
final cache = EasyCacheManager.auto();

// ดึงข้อมูล JSON จาก API
final userData = await cache.getJson('https://api.example.com/user/123');

// ดึงรูปภาพ
final imageBytes = await cache.getBytes('https://example.com/image.jpg');
```

### **วิธีที่ 2: EasyCacheManager.template() (ง่ายมาก!)**

เหมาะกับ: **คนที่รู้ประเภท app ที่กำลังทำ** - เลือก template ให้เหมาะกับ app

```dart
// สำหรับ E-commerce App
final cache = EasyCacheManager.template(AppType.ecommerce);

// สำหรับ Social Media App
final cache = EasyCacheManager.template(AppType.social);

// สำหรับ News App
final cache = EasyCacheManager.template(AppType.news);

// สำหรับ Game
final cache = EasyCacheManager.template(AppType.game);

// สำหรับ Productivity App
final cache = EasyCacheManager.template(AppType.productivity);
```

### **วิธีที่ 3: SimpleCacheManager (สำหรับมือใหม่มาก)**

⚠️ **หมายเหตุ**: SimpleCacheManager ยังไม่รองรับการ save/get แบบ key ตรงๆ ในเวอร์ชันนี้
แต่ยังใช้สำหรับ cache URL-based ได้ปกติ

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

// เรียกใช้ครั้งเดียวตอนเปิด app
await SimpleCacheManager.init();

// ใช้ instance สำหรับ URL-based caching
final cache = SimpleCacheManager.instance;

// Cache รูปภาพจาก URL
await SimpleCacheManager.cacheImage('https://example.com/image.jpg');

// ดึงรูปภาพที่ cache แล้ว
final imageBytes = await SimpleCacheManager.getImage('https://example.com/image.jpg');
```

## 👶 **วิธีใช้งานแบบ Step-by-Step สำหรับผู้เริ่มต้น**

### ตัวอย่างที่ 1: Cache ข้อมูลผู้ใช้ (JSON) - ตัวอย่างที่ถูกต้อง

```dart
import 'package:flutter/material.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // สร้าง cache manager แบบง่ายๆ
  final cache = EasyCacheManager.auto();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // โหลดข้อมูลผู้ใช้ (จะ cache อัตโนมัติ)
  Future<void> loadUserData() async {
    try {
      // ครั้งแรกจะโหลดจาก API, ครั้งต่อไปจะใช้ cache (เร็วมาก!)
      final data = await cache.getJson(
        'https://api.example.com/user/123',
        maxAge: Duration(hours: 1), // เก็บ cache 1 ชั่วโมง
      );

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Column(
        children: [
          Text('Name: ${userData?['name'] ?? 'Unknown'}'),
          Text('Email: ${userData?['email'] ?? 'Unknown'}'),
          ElevatedButton(
            onPressed: () {
              // ล้าง cache และโหลดข้อมูลใหม่
              cache.clearCache();
              loadUserData();
            },
            child: Text('Refresh Data'),
          ),
        ],
      ),
    );
  }
}
```

> **🔍 อธิบาย**: ตัวอย่างนี้แสดงการใช้งานจริงที่ถูกต้อง - ใช้ URL จริงเท่านั้น ไม่ใช่ key อิสระ
> Map<String, dynamic>? userData;
> bool isLoading = true;

@override
void initState() {
super.initState();
loadUserData();
}

// โหลดข้อมูลผู้ใช้ (จะ cache อัตโนมัติ)
Future<void> loadUserData() async {
try {
// ครั้งแรกจะโหลดจาก API, ครั้งต่อไปจะใช้ cache (เร็วมาก!)
final data = await cache.getJson(
'https://api.example.com/user/123',
maxAge: Duration(hours: 1), // เก็บ cache 1 ชั่วโมง
);

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }

}

@override
Widget build(BuildContext context) {
if (isLoading) {
return Center(child: CircularProgressIndicator());
}

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Column(
        children: [
          Text('Name: ${userData?['name'] ?? 'Unknown'}'),
          Text('Email: ${userData?['email'] ?? 'Unknown'}'),
          ElevatedButton(
            onPressed: () {
              // ล้าง cache และโหลดข้อมูลใหม่
              cache.clearCache();
              loadUserData();
            },
            child: Text('Refresh Data'),
          ),
        ],
      ),
    );

}
}

````

### ตัวอย่างที่ 2: Cache รูปภาพ

```dart
import 'package:flutter/material.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

class CachedImageExample extends StatelessWidget {
  // ใช้ template สำหรับ app ประเภท social media
  final cache = EasyCacheManager.template(AppType.social);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                // รูปภาพจะถูก cache อัตโนมัติ - ไม่ต้องโหลดซ้ำ!
                CachedNetworkImageWidget(
                  cacheManager: cache,
                  imageUrl: 'https://picsum.photos/300/200?random=$index',
                  width: 300,
                  height: 200,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                Text('Image $index'),
              ],
            ),
          );
        },
      ),
    );
  }
}
````

### ตัวอย่างที่ 3: เว็บไซต์ข่าว (News App)

```dart
import 'package:flutter/material.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

class NewsApp extends StatefulWidget {
  @override
  _NewsAppState createState() => _NewsAppState();
}

class _NewsAppState extends State<NewsApp> {
  // ใช้ template สำหรับ app ข่าว - จะตั้งค่า cache ให้เหมาะสมอัตโนมัติ
  final cache = EasyCacheManager.template(AppType.news);
  List<dynamic> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  Future<void> loadNews() async {
    try {
      // ข่าวจะ cache เป็นเวลา 10 นาที (ตั้งค่าอัตโนมัติใน news template)
      final response = await cache.getJson(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=YOUR_KEY',
      );

      setState(() {
        articles = response['articles'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() { isLoading = true; });
              loadNews();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadNews,
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return Card(
                    child: ListTile(
                      title: Text(article['title'] ?? ''),
                      subtitle: Text(article['description'] ?? ''),
                      leading: article['urlToImage'] != null
                          ? CachedNetworkImageWidget(
                              cacheManager: cache,
                              imageUrl: article['urlToImage'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
```

## 🎯 **เทมเพลตพร้อมใช้งาน (Templates)**

ไม่ต้องคิดเรื่องการตั้งค่า - เลือกแค่ประเภท app ของคุณ:

```dart
// 🛒 สำหรับ E-commerce (สินค้า, รูปภาพ, รีวิว)
final ecommerceCache = EasyCacheManager.template(AppType.ecommerce);

// 📱 สำหรับ Social Media (โพสต์, รูปภาพ, คอมเมนต์)
final socialCache = EasyCacheManager.template(AppType.social);

// 📰 สำหรับ News App (บทความ, รูปข่าว)
final newsCache = EasyCacheManager.template(AppType.news);

// 📊 สำหรับ Productivity App (เอกสาร, ไฟล์)
final productivityCache = EasyCacheManager.template(AppType.productivity);

// 🎮 สำหรับ Game/Entertainment (assets, scores)
final gameCache = EasyCacheManager.template(AppType.game);

// 📚 สำหรับ Education (บทเรียน, วิดีโอ)
final educationCache = EasyCacheManager.template(AppType.education);
```

## ⚡ **การใช้งานแบบง่ายที่สุด (SimpleCacheManager)**

สำหรับใครที่ไม่ต้องการเห็น architecture เลย:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ตั้งค่าแค่ครั้งเดียว
  await SimpleCacheManager.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? cachedData;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // ใช้งานแบบง่ายๆ - ไม่ต้องสร้าง instance
    final data = await SimpleCacheManager.getJson(
      'https://api.example.com/data',
      maxAge: Duration(minutes: 30),
    );

    setState(() {
      cachedData = data.toString();
    });
  }

  Future<void> saveData() async {
    // บันทึกข้อมูลลง cache
    await SimpleCacheManager.save('user_preference', {
      'theme': 'dark',
      'language': 'th',
    });
  }

  Future<void> loadSavedData() async {
    // โหลดข้อมูลจาก cache
    final preferences = await SimpleCacheManager.get('user_preference');
    print('Saved preferences: $preferences');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Cache Example')),
      body: Column(
        children: [
          Text('Cached Data: ${cachedData ?? 'Loading...'}'),
          ElevatedButton(
            onPressed: saveData,
            child: Text('Save Preferences'),
          ),
          ElevatedButton(
            onPressed: loadSavedData,
            child: Text('Load Preferences'),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 **คำถามที่พบบ่อยสำหรับมือใหม่**

### Q: ต้องตั้งค่าอะไรบ้างมั้ย?

**A:** ไม่ต้องเลย! ใช้ `EasyCacheManager.auto()` ระบบจะตั้งค่าให้เองทั้งหมด

### Q: ข้อมูลเก็บที่ไหน?

**A:** เก็บในเครื่องของผู้ใช้ (local storage) อัตโนมัติ - ทำงานได้ทั้ง online และ offline

### Q: Cache จะหมดอายุเมื่อไหร?

**A:** ตั้งได้เองผ่าน `maxAge` หรือให้ระบบจัดการอัตโนมัติ (default 24 ชั่วโมง)

### Q: จะล้าง cache ยังไง?

**A:** เรียก `cache.clearCache()` หรือ `SimpleCacheManager.clear()`

### Q: ใช้งานบน Web ได้มั้ย?

**A:** ได้! ทำงานได้ทุก platform (Web, iOS, Android, Desktop)

### Q: เก็บรูปภาพได้มั้ย?

**A:** ได้! ใช้ `cache.getBytes()` หรือ `CachedNetworkImageWidget`

### Q: ปลอดภัยมั้ย?

**A:** ปลอดภัย ข้อมูลเก็บในเครื่องเท่านั้น ไม่ส่งไปที่ไหน

## 🎓 **ขั้นตอนต่อไป**

เมื่อคุณคุ้นเคยแล้ว สามารถเรียนรู้เพิ่มเติมได้:

1. **[📖 Configuration Guide](CONFIGURATION_GUIDE.md)** - เรียนรู้การตั้งค่าแบบละเอียด
2. **[🏗️ Architecture Guide](ARCHITECTURE_GUIDE.md)** - เข้าใจ Clean Architecture
3. **[⚡ Performance Guide](PERFORMANCE_GUIDE.md)** - เทคนิคเพิ่มประสิทธิภาพ
4. **[🔧 Advanced Features](ADVANCED_GUIDE.md)** - ฟีเจอร์ขั้นสูง

## 💡 **เคล็ดลับสำหรับมือใหม่**

### ✅ **ควรทำ**

- ใช้ template ที่เหมาะกับประเภท app ของคุณ
- ตั้งค่า `maxAge` ให้เหมาะสมกับความถี่ของข้อมูล
- ใช้ `CachedNetworkImageWidget` สำหรับรูปภาพ
- เรียก `clearCache()` เมื่อ user ล็อกเอ้า

### ❌ **ไม่ควรทำ**

- ไม่ cache ข้อมูลที่มีความปลอดภัยสูง (password, token)
- ไม่ตั้งค่า cache ขนาดใหญ่เกินไปบนมือถือ
- ไม่ลืม handle error เมื่อเครือข่ายขาด
- ไม่ cache ข้อมูลที่เปลี่ยนแปลงบ่อยมาก

---

**🎯 สรุป**: Easy Cache Manager ออกแบบให้ผู้เริ่มต้นใช้งานได้ทันที โดยไม่ต้องเข้าใจเทคนิคซับซ้อน แค่เลือก template ที่เหมาะสมและเริ่มใช้งาน!

**💬 ต้องการความช่วยเหลือ?** เปิด issue ใน [GitHub](https://github.com/kidpech/easy_cache_manager/issues) หรือดูตัวอย่างเพิ่มเติมใน [example folder](example/)
