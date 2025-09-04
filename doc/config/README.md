# ⚙️ Smart Configuration - เลือกแบบไม่งง

> **🎯 หยุดกังวลเรื่อง config!**
>
> เรามี template สำเร็จรูปให้เลือก + AI ที่แนะนำ config ที่เหมาะกับแอปคุณ

## 🤖 AI-Powered Auto Configuration

### 🚀 Smart Auto-Detection (แนะนำ!)

ปล่อยให้ AI เลือก config ที่เหมาะกับแอปคุณ:

```dart
// เพียงแค่นี้! AI จะวิเคราะห์แอปและเลือก config ที่เหมาะสม
final cache = EasyCacheManager.auto();

// หรือระบุข้อมูลเพิ่มเติมให้ AI
final cache = EasyCacheManager.smart(
  expectedUsers: 1000,      // คาดว่าจะมี user เท่าไหร่
  dataTypes: ['images', 'json', 'videos'], // ประเภทข้อมูลที่จะ cache
  platform: 'mobile',       // แพลตฟอร์มหลัก
  importance: 'high',       // ความสำคัญของการ cache
);
```

## 📱 Template สำเร็จรูป - Copy & Paste ได้เลย!

### 🛒 E-Commerce App

เหมาะสำหรับ: แอปช้อปปิ้ง, marketplace

```dart
final cache = CacheManager(
  config: EcommerceConfig(
    // สินค้า cache นาน (ไม่เปลี่ยนบ่อย)
    productCacheTime: Duration(hours: 12),
    // รูปสินค้า cache นานมาก
    imageCacheTime: Duration(days: 7),
    // cart cache สั้น (อาจเปลี่ยนบ่อย)
    cartCacheTime: Duration(minutes: 30),
    // ขนาด cache ใหญ่ (เก็บรูปเยอะ)
    maxSize: 500 * 1024 * 1024, // 500MB
    // เปิด compression สำหรับประหยัด space
    enableCompression: true,
  ),
);

// การใช้งาน
await cache.getJson(
  'https://api.shop.com/products',
  maxAge: cache.config.productCacheTime,
);
```

### 📰 News/Blog App

เหมาะสำหรับ: แอปข่าว, บล็อก, สื่อ

```dart
final cache = CacheManager(
  config: NewsConfig(
    // ข่าวด่วน cache สั้น
    breakingNewsCacheTime: Duration(minutes: 5),
    // บทความ cache นาน
    articleCacheTime: Duration(hours: 24),
    // รูปข่าว cache ปานกลาง
    imageCacheTime: Duration(hours: 6),
    // ขนาดกลาง (เน้นข้อความ)
    maxSize: 200 * 1024 * 1024, // 200MB
    // เปิดออฟไลน์โหมด
    enableOffline: true,
  ),
);

// การใช้งาน
await cache.getJson(
  'https://api.news.com/breaking',
  maxAge: cache.config.breakingNewsCacheTime,
);
```

### 📱 Social Media App

เหมาะสำหรับ: แอปโซเชียล, แชต, ชุมชน

```dart
final cache = CacheManager(
  config: SocialConfig(
    // โพสต์ cache สั้น (อัปเดตบ่อย)
    postCacheTime: Duration(minutes: 15),
    // รูปโปรไฟล์ cache นาน (ไม่เปลี่ยนบ่อย)
    profileImageCacheTime: Duration(days: 3),
    // ข้อความแชต cache ปานกลาง
    messageCacheTime: Duration(hours: 2),
    // ขนาดใหญ่ (รูปภาพเยอะ)
    maxSize: 800 * 1024 * 1024, // 800MB
    // เปิด encryption (ข้อมูลส่วนตัว)
    enableEncryption: true,
  ),
);
```

### 💼 Productivity App

เหมาะสำหรับ: แอปงาน, note-taking, task management

```dart
final cache = CacheManager(
  config: ProductivityConfig(
    // เอกสาร cache นานมาก (ไม่เปลี่ยนบ่อย)
    documentCacheTime: Duration(days: 30),
    // draft/ข้อมูลชั่วคราว cache สั้น
    draftCacheTime: Duration(hours: 1),
    // ไฟล์แนบ cache นาน
    attachmentCacheTime: Duration(days: 7),
    // ขนาดกลาง
    maxSize: 300 * 1024 * 1024, // 300MB
    // เปิด sync (สำคัญมาก)
    enableSync: true,
    // backup ข้อมูล
    enableBackup: true,
  ),
);
```

### 🎮 Game App

เหมาะสำหรับ: เกม, interactive app

```dart
final cache = CacheManager(
  config: GameConfig(
    // asset เกม cache นานมาก (ไม่เปลี่ยน)
    assetCacheTime: Duration(days: 90),
    // leaderboard cache สั้น (เปลี่ยนบ่อย)
    leaderboardCacheTime: Duration(minutes: 5),
    // player data cache ปานกลาง
    playerDataCacheTime: Duration(hours: 12),
    // ขนาดใหญ่มาก (asset เยอะ)
    maxSize: 2 * 1024 * 1024 * 1024, // 2GB
    // เปิด compression สูงสุด
    compressionLevel: 9,
    // preload สำคัญ
    enablePreloading: true,
  ),
);
```

## 📊 Size-Based Templates

### 🔸 Small App (< 50MB cache)

```dart
final cache = CacheManager.small(
  features: ['basic_cache', 'offline_support'],
  maxSize: 25 * 1024 * 1024, // 25MB
  cleanupThreshold: 0.8, // ลบเมื่อเต็ม 80%
);
```

### 🔹 Medium App (50-200MB cache)

```dart
final cache = CacheManager.medium(
  features: ['compression', 'analytics', 'smart_cleanup'],
  maxSize: 150 * 1024 * 1024, // 150MB
  evictionPolicy: 'lru', // ลบของที่ไม่ได้ใช้นาน
);
```

### 🔷 Large App (200MB+ cache)

```dart
final cache = CacheManager.large(
  features: ['encryption', 'multiple_policies', 'advanced_analytics'],
  maxSize: 1 * 1024 * 1024 * 1024, // 1GB
  backgroundSync: true, // sync ใน background
);
```

## 🎯 Platform-Specific Templates

### 📱 Mobile-First

```dart
final cache = CacheManager.mobile(
  // เน้นประหยัด battery และ data
  batteryOptimized: true,
  wifiOnlySync: true,
  lowMemoryMode: true,
  maxSize: 100 * 1024 * 1024, // 100MB
);
```

### 💻 Web-First

```dart
final cache = CacheManager.web(
  // ใช้ browser storage
  useLocalStorage: true,
  useIndexedDB: true,
  maxSize: 50 * 1024 * 1024, // 50MB (browser limit)
  compression: 'gzip', // เหมาะกับ web
);
```

### 🖥️ Desktop-First

```dart
final cache = CacheManager.desktop(
  // ใช้พื้นที่เก็บข้อมูลมากได้
  maxSize: 2 * 1024 * 1024 * 1024, // 2GB
  enableFileWatcher: true, // ดู file changes
  nativePaths: true, // ใช้ path แบบ native
);
```

## 🧪 Development vs Production

### 🔧 Development Mode

```dart
final cache = CacheManager.development(
  // เปิด logging เต็ม
  verboseLogging: true,
  // cache สั้น (เห็นการเปลี่ยนแปลงเร็ว)
  defaultMaxAge: Duration(seconds: 30),
  // เปิดดู cache stats
  enableDebugStats: true,
  // ลบ cache เมื่อ restart
  clearOnRestart: true,
);
```

### 🚀 Production Mode

```dart
final cache = CacheManager.production(
  // ปิด logging (ประสิทธิภาพ)
  enableLogging: false,
  // cache นาน (ประสิทธิภาพ)
  defaultMaxAge: Duration(hours: 24),
  // error recovery
  enableErrorRecovery: true,
  // analytics
  enableAnalytics: true,
);
```

## 🎛️ Custom Configuration Builder

### 🖼️ Image-Heavy App

```dart
final cache = ConfigBuilder()
  .forImageApp()
  .withSize(1024) // 1GB
  .withCompression('webp') // รูปภาพ
  .withLazyLoading(true)
  .withPreloading(['thumbnails'])
  .build();
```

### 💰 Financial App

```dart
final cache = ConfigBuilder()
  .forFinancialApp()
  .withEncryption('AES256')
  .withShortCache() // ข้อมูลการเงินต้องใหม่
  .withAuditLog(true) // บันทึกการเข้าถึง
  .withSecurityLevel('high')
  .build();
```

## 📋 Configuration Comparison

| Template       | Size   | Features              | Use Case   |
| -------------- | ------ | --------------------- | ---------- |
| **Simple**     | 25MB   | Cache, Offline        | Basic apps |
| **Ecommerce**  | 500MB  | Compression, Images   | Shopping   |
| **News**       | 200MB  | Offline, Fast refresh | Media      |
| **Social**     | 800MB  | Encryption, Real-time | Social     |
| **Game**       | 2GB    | Preload, Assets       | Gaming     |
| **Enterprise** | Custom | All features          | Business   |

## 🔧 Configuration Wizard (Interactive)

```dart
// ตอบคำถาม AI จะแนะนำ config
final config = await ConfigWizard.run([
  'What type of app? (ecommerce/news/social/game/other)',
  'Expected concurrent users? (1-10/10-100/100+)',
  'Main data types? (json/images/videos/files)',
  'Platform priority? (mobile/web/desktop)',
  'Performance priority? (speed/storage/battery)',
]);

final cache = CacheManager(config: config);
```

## 🎯 Performance Optimization Tips

### ⚡ Speed-First

```dart
final cache = CacheManager(
  config: CacheConfig(
    // เน้นความเร็ว
    evictionPolicy: 'lru', // เร็วที่สุด
    enableCompression: false, // ไม่ compress (เร็วกว่า)
    enableEncryption: false, // ไม่ encrypt (เร็วกว่า)
    cleanupThreshold: 0.9, // ลบน้อย
    enablePreloading: true, // โหลดล่วงหน้า
  ),
);
```

### 💾 Storage-First

```dart
final cache = CacheManager(
  config: CacheConfig(
    // เน้นประหยัดพื้นที่
    enableCompression: true, // compress เต็มที่
    compressionLevel: 9, // สูงสุด
    cleanupThreshold: 0.7, // ลบบ่อย
    evictionPolicy: 'size', // ลบไฟล์ใหญ่ก่อน
    enableDuplicateDetection: true, // หาข้อมูลซ้ำ
  ),
);
```

### 🔋 Battery-First

```dart
final cache = CacheManager(
  config: CacheConfig(
    // เน้นประหยัดแบต
    backgroundSync: false, // ไม่ sync background
    wifiOnlyOperations: true, // ใช้แค่ wifi
    lowPowerMode: true, // โหมดประหยัดไฟ
    reducedRefreshRate: true, // refresh ช้าลง
  ),
);
```

---

> 🎯 **ตอนนี้คุณไม่ต้องงงกับ configuration แล้ว!**
>
> เลือก template ที่เหมาะกับแอปคุณ หรือให้ AI เลือกให้ ✨

## 📞 ต้องการความช่วยเหลือ?

- 🤖 **AI Config Assistant**: [config.easycachemanager.dev](https://config.easycachemanager.dev)
- 💬 **Community**: [Discord](https://discord.gg/easy-cache-manager)
- 📧 **Direct Support**: config-help@easycachemanager.dev

_🚀 ไปสร้างแอปเจ๋งๆ กันเถอะ!_
