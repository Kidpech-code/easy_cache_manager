# ⚙️ **Easy Cache Manager - คู่มือ Configuration แบบละเอียด**

> 🎯 **สำหรับใคร**: ผู้ที่ต้องการปรับแต่ง cache ให้เหมาะสมกับความต้องการเฉพาะ

## 🎚️ **ระดับความซับซ้อนของ Configuration**

### 1. 👶 **ระดับเริ่มต้น (Zero Config)**

```dart
// ใช้ได้ทันที - ไม่ต้องตั้งค่าอะไร
final cache = EasyCacheManager.auto();
```

### 2. 📱 **ระดับกลาง (Template Based)**

```dart
// เลือก template ตามประเภท app
final cache = EasyCacheManager.template(AppType.ecommerce);
```

### 3. 🔧 **ระดับขั้นสูง (Custom Configuration)**

```dart
// ปรับแต่งทุกรายละเอียด
final cache = CacheManager(config: AdvancedCacheConfig(...));
```

## 📋 **การเลือก Configuration ที่เหมาะสม**

### 🤔 **คำถามสำหรับเลือก Config**

| คำถาม                           | ตอบ "ใช่" → ใช้ Config | ตอบ "ไม่" → ใช้ Config |
| ------------------------------- | ---------------------- | ---------------------- |
| เพิ่งเริ่มเรียน Flutter?        | **Zero Config**        | ดูคำถามต่อไป           |
| แค่ต้องการ cache API responses? | **Template Based**     | ดูคำถามต่อไป           |
| ต้องการควบคุมการทำงานทุกด้าน?   | **Custom Config**      | **Template Based**     |
| ต้องการ encryption/compression? | **Advanced Config**    | **Standard Config**    |
| มี requirements พิเศษ?          | **Enterprise Config**  | **Standard Config**    |

## 📚 **Template Configurations (แนะนำ)**

### 🛒 **E-commerce Template**

```dart
final cache = EasyCacheManager.template(AppType.ecommerce);

// เทียบเท่ากับ:
CacheManager(config: CacheConfig(
  maxCacheSize: 200 * 1024 * 1024,    // 200MB - รูปสินค้าเยอะ
  stalePeriod: Duration(days: 5),      // ข้อมูลสินค้าค่อนข้างคงที่
  maxAge: Duration(minutes: 30),       // ราคาอาจเปลี่ยนบ่อย
  cleanupThreshold: 0.8,               // ล้าง cache เมื่อใช้งาน 80%
  evictionPolicy: 'lru',               // ลบข้อมูลที่ไม่ได้ใช้
  enableCompression: true,             // บีบอัดเพื่อประหยัดพื้นที่
  enableEncryption: false,             // ไม่เข้ารหัส (ข้อมูลสาธารณะ)
  enableMetrics: true,                 // เก็บสถิติการใช้งาน
));
```

**เหมาะสำหรับ**: แอปขายของ, marketplace, catalog app
**จุดเด่น**: เก็บรูปภาพสินค้าได้เยอะ, รองรับข้อมูลราคาที่เปลี่ยนบ่อย

### 📱 **Social Media Template**

```dart
final cache = EasyCacheManager.template(AppType.social);

// เทียบเท่ากับ:
CacheManager(config: CacheConfig(
  maxCacheSize: 300 * 1024 * 1024,    // 300MB - รูปภาพ + วิดีโอ
  stalePeriod: Duration(days: 2),      // โซเชียลเปลี่ยนเร็ว
  maxAge: Duration(minutes: 15),       // โพสต์ใหม่ต้องอัปเดตเร็ว
  cleanupThreshold: 0.8,
  evictionPolicy: 'lru',               // ลบโพสต์เก่าที่ไม่ได้ดู
  enableCompression: true,
  enableEncryption: false,
  backgroundSync: true,                // ดาวน์โหลดล่วงหน้า
));
```

**เหมาะสำหรับ**: Facebook-like apps, Instagram-like apps
**จุดเด่น**: รองรับรูปภาพเยอะ, อัปเดตเนื้อหาบ่อย

### 📰 **News Template**

```dart
final cache = EasyCacheManager.template(AppType.news);

// เทียบเท่ากับ:
CacheManager(config: CacheConfig(
  maxCacheSize: 150 * 1024 * 1024,    // 150MB - บทความ + รูปข่าว
  stalePeriod: Duration(days: 1),      // ข่าวเก่าไม่น่าสนใจ
  maxAge: Duration(minutes: 10),       // ข่าวด่วนต้องใหม่
  cleanupThreshold: 0.8,
  evictionPolicy: 'ttl',               // ลบตามเวลา
  enableCompression: true,
  compressionType: 'gzip',             // บีบอัดข้อความได้ดี
));
```

**เหมาะสำหรับ**: แอปข่าว, blog app, content reader
**จุดเด่น**: อัปเดตข่าวบ่อย, ประหยัดพื้นที่ด้วยการบีบอัด

### 📊 **Productivity Template**

```dart
final cache = EasyCacheManager.template(AppType.productivity);

// เทียบเท่ากับ:
CacheManager(config: CacheConfig(
  maxCacheSize: 500 * 1024 * 1024,    // 500MB - เอกสารขนาดใหญ่
  stalePeriod: Duration(days: 14),     // ข้อมูลงานค่อนข้างคงที่
  maxAge: Duration(hours: 2),          // โปรเจ็คอัปเดตไม่บ่อย
  cleanupThreshold: 0.7,               // เก็บข้อมูลไว้นานหน่อย
  evictionPolicy: 'lfu',               // เก็บไฟล์ที่ใช้บ่อย
  enableCompression: true,
  enableEncryption: true,              // ข้อมูลงานควรเข้ารหัส
  encryptionKey: 'your-32-character-secret-key!!',
));
```

**เหมาะสำหรับ**: แอปจัดการงาน, office suite, cloud storage
**จุดเด่น**: เก็บไฟล์ใหญ่ได้, มีความปลอดภัยสูง

## 🔧 **Custom Configuration แบบละเอียด**

### 📦 **CacheConfig Parameters**

```dart
CacheManager(
  config: CacheConfig(
    // === พื้นฐาน ===
    maxCacheSize: 100 * 1024 * 1024,    // ขนาด cache สูงสุด (bytes)
    stalePeriod: Duration(days: 7),      // เก็บข้อมูลไว้นานแค่ไหน
    maxAge: Duration(hours: 24),         // ข้อมูลใหม่ถือว่าเก่าเมื่อไหร
    cacheName: 'my_app_cache',           // ชื่อ cache (unique per app)

    // === การจัดการพื้นที่ ===
    cleanupThreshold: 0.8,               // ล้าง cache เมื่อใช้ 80%
    autoCleanup: true,                   // ล้างอัตโนมัติ
    maxCacheEntries: 2000,               // จำนวน entries สูงสุด

    // === Network & Offline ===
    enableOfflineMode: true,             // ใช้งานแบบ offline
    maxAge: Duration(hours: 6),          // ข้อมูลสด valid นานแค่ไหน

    // === การทำงาน ===
    enableLogging: false,                // แสดง debug logs
    enableMetrics: true,                 // เก็บสถิติการใช้งาน
  ),
);
```

### 🚀 **AdvancedCacheConfig (สำหรับผู้ที่เข้าใจดี)**

```dart
CacheManager(
  config: AdvancedCacheConfig(
    // === การบีบอัด ===
    enableCompression: true,             // เปิดการบีบอัด
    compressionType: 'gzip',             // ประเภท: gzip, deflate, lz4
    compressionLevel: 6,                 // ระดับ 1-9 (9 = บีบแน่นสุด แต่ช้า)
    compressionThreshold: 1024,          // บีบอัดไฟล์ที่ใหญ่กว่า 1KB

    // === การเข้ารหัส ===
    enableEncryption: true,              // เปิดการเข้ารหัส
    encryptionKey: 'your-32-character-secret-key!!', // คีย์ 32 ตัวอักษร

    // === Eviction Policies ===
    evictionPolicy: 'lru',               // วิธีลบข้อมูล: lru, lfu, fifo, ttl

    // === Background Operations ===
    backgroundSync: true,                // ดาวน์โหลดข้อมูลล่วงหน้า
    syncInterval: Duration(hours: 2),    // ช่วงเวลา background sync

    // === Performance ===
    enableMetrics: true,                 // เก็บ performance metrics
    enableBenchmarking: true,            // เปิดใช้ benchmark tools

    // === Platform Specific ===
    webCacheStrategy: 'memory',          // สำหรับ web: memory, localStorage
    mobileCacheStrategy: 'hybrid',       // สำหรับ mobile: file, memory, hybrid
  ),
);
```

## 🎯 **การเลือกค่าที่เหมาะสม**

### 📏 **maxCacheSize (ขนาด Cache)**

| ประเภทแอป        | แนะนำ         | เหตุผล                         |
| ---------------- | ------------- | ------------------------------ |
| **เล็ก/ทดลอง**   | 10-25 MB      | ประหยัดพื้นที่                 |
| **กลาง/ปกติ**    | 50-100 MB     | สมดุลระหว่างความเร็วและพื้นที่ |
| **ใหญ่/รูปเยอะ** | 200-500 MB    | ประสิทธิภาพสูงสุด              |
| **Enterprise**   | 500 MB - 1 GB | ไม่จำกัดแทบจะ                  |

```dart
// ตัวอย่างการคำนวณขนาดที่เหมาะสม
final estimatedSize =
  (numberOfImages * averageImageSize) +
  (numberOfApiResponses * averageResponseSize) +
  (10 * 1024 * 1024); // บัฟเฟอร์ 10MB

final maxCacheSize = (estimatedSize * 1.5).round(); // เผื่อไว้ 50%
```

### ⏰ **stalePeriod vs maxAge**

```dart
// stalePeriod: ข้อมูลจะถูกลบออกจาก cache เมื่อไหร
stalePeriod: Duration(days: 7),    // ลบทิ้งหลัง 7 วัน

// maxAge: ข้อมูลจะ "เก่า" เมื่อไหร (แต่ยังใช้งานได้)
maxAge: Duration(hours: 1),        // ถือว่าเก่าหลัง 1 ชม. (แต่ยังใช้ได้)
```

**กรณีตัวอย่าง**:

- **ข้อมูลผู้ใช้**: `stalePeriod: 30 วัน`, `maxAge: 1 ชั่วโมง`
- **ราคาสินค้า**: `stalePeriod: 7 วัน`, `maxAge: 30 นาที`
- **ข่าวสาร**: `stalePeriod: 1 วัน`, `maxAge: 10 นาที`
- **รูปโปรไฟล์**: `stalePeriod: 30 วัน`, `maxAge: 1 วัน`

### 🗑️ **Eviction Policies (วิธีลบข้อมูล)**

```dart
// LRU (Least Recently Used) - ลบสิ่งที่ไม่ได้ใช้นานที่สุด
evictionPolicy: 'lru',     // เหมาะสำหรับแอปทั่วไป

// LFU (Least Frequently Used) - ลบสิ่งที่ใช้น้อยที่สุด
evictionPolicy: 'lfu',     // เหมาะสำหรับแอป productivity

// FIFO (First In, First Out) - ลบสิ่งที่เข้ามาก่อน
evictionPolicy: 'fifo',    // เหมาะสำหรับข้อมูลที่มีการอัปเดตเป็นคลื่น

// TTL (Time To Live) - ลบตามเวลา
evictionPolicy: 'ttl',     // เหมาะสำหรับข่าว, ข้อมูลที่มีเวลา

// Size-based - ลบไฟล์ใหญ่ก่อน
evictionPolicy: 'size-based',  // เหมาะเมื่อพื้นที่จำกัด
```

### 🗜️ **Compression Settings**

```dart
// เปิดการบีบอัดเมื่อไหร?
enableCompression: true,              // แนะนำสำหรับ production
compressionType: 'gzip',              // gzip = ดี, lz4 = เร็ว
compressionLevel: 6,                  // 1-3 = เร็ว, 6-9 = บีบแน่น
compressionThreshold: 1024,           // บีบเฉพาะไฟล์ > 1KB
```

**แนวทางการเลือก**:

- **Text/JSON**: `gzip` level `6` (บีบได้ดีมาก)
- **Images**: ไม่ต้องบีบ (บีบไม่ได้แล้ว)
- **Binary Data**: `lz4` (เร็วกว่า)
- **Mobile**: level `3-6` (ประหยัด CPU)
- **Desktop**: level `6-9` (ประสิทธิภาพสูงสุด)

## 🎚️ **Dynamic Configuration**

### 📊 **Auto-Configuration ตามการใช้งาน**

```dart
class SmartCacheManager {
  static CacheManager createAdaptive() {
    // ตรวจสอบ platform
    final isWeb = kIsWeb;
    final isMobile = Platform.isIOS || Platform.isAndroid;

    // ตรวจสอบพื้นที่ว่าง
    final availableSpace = await _getAvailableSpace();

    // คำนวณขนาด cache ที่เหมาะสม
    final maxSize = _calculateOptimalSize(availableSpace, isWeb, isMobile);

    return CacheManager(
      config: CacheConfig(
        maxCacheSize: maxSize,
        stalePeriod: isWeb
          ? Duration(hours: 6)    // Web: เก็บไม่นาน
          : Duration(days: 7),    // Mobile: เก็บนานได้
        enableCompression: !isWeb, // Web ไม่บีบ (ช้า)
        enableEncryption: !isWeb,  // Web ไม่เข้ารหัส
        evictionPolicy: isMobile ? 'lru' : 'lfu',
      ),
    );
  }

  static int _calculateOptimalSize(int availableSpace, bool isWeb, bool isMobile) {
    if (isWeb) {
      return 25 * 1024 * 1024; // 25MB สำหรับ web
    }

    if (isMobile) {
      // ใช้ 5% ของพื้นที่ว่าง แต่ไม่เกิน 500MB
      return min(availableSpace * 0.05, 500 * 1024 * 1024).round();
    }

    // Desktop: ใช้ได้เยอะหน่อย
    return min(availableSpace * 0.1, 1024 * 1024 * 1024).round(); // สูงสุด 1GB
  }
}
```

### 🎯 **Configuration Wizard**

```dart
class CacheConfigWizard {
  static Future<CacheConfig> generateConfig() async {
    print('🧙‍♂️ Cache Configuration Wizard');
    print('Answer a few questions to get the perfect setup!\n');

    // คำถาม 1: ประเภทแอป
    final appType = await _askAppType();

    // คำถาม 2: ข้อมูลหลักคืออะไร
    final dataType = await _askDataType();

    // คำถาม 3: ความถี่ในการอัปเดต
    final updateFrequency = await _askUpdateFrequency();

    // คำถาม 4: ความปลอดภัย
    final securityLevel = await _askSecurityLevel();

    // สร้าง config ตามคำตอบ
    return _buildConfigFromAnswers(appType, dataType, updateFrequency, securityLevel);
  }

  static Future<String> _askAppType() async {
    print('1. What type of app are you building?');
    print('   a) E-commerce/Shopping');
    print('   b) Social Media');
    print('   c) News/Blog');
    print('   d) Productivity/Work');
    print('   e) Game/Entertainment');
    print('   f) Other');

    // ในตัวอย่างจริงจะมีการรับ input จาก user
    return 'ecommerce';
  }

  static CacheConfig _buildConfigFromAnswers(
    String appType, String dataType, String updateFreq, String security) {

    // กฎในการสร้าง config
    int maxSize = 100 * 1024 * 1024; // default 100MB
    Duration stalePeriod = Duration(days: 7);
    Duration maxAge = Duration(hours: 1);
    bool enableEncryption = false;
    String evictionPolicy = 'lru';

    // ปรับตาม app type
    switch (appType) {
      case 'ecommerce':
        maxSize = 200 * 1024 * 1024;
        maxAge = Duration(minutes: 30);
        break;
      case 'social':
        maxSize = 300 * 1024 * 1024;
        stalePeriod = Duration(days: 2);
        maxAge = Duration(minutes: 15);
        break;
      case 'news':
        maxSize = 150 * 1024 * 1024;
        stalePeriod = Duration(days: 1);
        maxAge = Duration(minutes: 10);
        evictionPolicy = 'ttl';
        break;
    }

    // ปรับตาม security
    if (security == 'high') {
      enableEncryption = true;
    }

    // ปรับตาม update frequency
    if (updateFreq == 'realtime') {
      maxAge = Duration(minutes: 5);
    } else if (updateFreq == 'daily') {
      maxAge = Duration(hours: 12);
    }

    return CacheConfig(
      maxCacheSize: maxSize,
      stalePeriod: stalePeriod,
      maxAge: maxAge,
      enableEncryption: enableEncryption,
      evictionPolicy: evictionPolicy,
      enableCompression: true,
      enableMetrics: true,
    );
  }
}

// การใช้งาน wizard
final config = await CacheConfigWizard.generateConfig();
final cache = CacheManager(config: config);
```

## ⚠️ **ข้อควรระวังและคำแนะนำ**

### ✅ **Best Practices**

```dart
// ✅ ใช้ template เป็นจุดเริ่มต้น
final cache = EasyCacheManager.template(AppType.ecommerce);

// ✅ ตั้งชื่อ cache ให้ unique
CacheConfig(cacheName: 'myapp_v1_cache');

// ✅ ใช้ encryption สำหรับข้อมูลสำคัญ
CacheConfig(
  enableEncryption: true,
  encryptionKey: 'your-secure-32-character-key!!!!',
);

// ✅ ตั้งค่า compression สำหรับข้อมูลขนาดใหญ่
CacheConfig(
  enableCompression: true,
  compressionThreshold: 1024, // บีบไฟล์ที่ใหญ่กว่า 1KB
);

// ✅ เก็บ metrics เพื่อติดตามประสิทธิภาพ
CacheConfig(enableMetrics: true);
```

### ❌ **สิ่งที่ไม่ควรทำ**

```dart
// ❌ อย่าตั้ง cache ใหญ่เกินไปบนมือถือ
CacheConfig(maxCacheSize: 2000 * 1024 * 1024); // 2GB = มากเกินไป!

// ❌ อย่าใช้ encryption key ที่ง่าย
CacheConfig(encryptionKey: '12345'); // สั้นเกินไป!

// ❌ อย่าตั้ง maxAge สั้นเกินไป (จะเรียก API บ่อย)
CacheConfig(maxAge: Duration(seconds: 5)); // สั้นเกินไป!

// ❌ อย่าปิด autoCleanup หากไม่มี cleanup manual
CacheConfig(autoCleanup: false); // อาจจะเต็มได้

// ❌ อย่าใช้ compression กับรูปภาพ (บีบไม่ได้แล้ว)
// รูป JPEG/PNG บีบแล้ว - การบีบเพิ่มจะทำให้ช้า
```

### 🔍 **การ Debug และ Troubleshoot**

```dart
// เปิด logging เพื่อดู debug info
CacheConfig(enableLogging: true);

// ตรวจสอบสถิติ cache
final stats = await cacheManager.getStats();
print('Hit rate: ${stats.hitRate}%');
print('Total size: ${stats.totalSizeInMB} MB');

// ตรวจสอบ configuration validation
try {
  final config = CacheConfig(maxCacheSize: -100); // ผิด!
} catch (e) {
  print('Configuration error: $e');
}
```

## 🚀 **ขั้นตอนต่อไป**

เมื่อเข้าใจ configuration แล้ว ลองศึกษา:

1. **[🏗️ Architecture Deep Dive](ARCHITECTURE_GUIDE.md)** - เข้าใจโครงสร้างภายใน
2. **[⚡ Performance Optimization](PERFORMANCE_GUIDE.md)** - เทคนิคเพิ่มความเร็ว
3. **[🔐 Security Best Practices](SECURITY_GUIDE.md)** - ความปลอดภัย
4. **[📊 Monitoring & Analytics](MONITORING_GUIDE.md)** - การติดตามประสิทธิภาพ

---

**💡 สรุป**: Configuration ที่ดีจะทำให้แอปของคุณเร็วขึ้นและใช้ทรัพยากรอย่างมีประสิทธิภาพ เริ่มจาก template แล้วค่อยปรับแต่งตามความต้องการ!
