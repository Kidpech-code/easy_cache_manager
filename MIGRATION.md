# Migration Guide

## From v1.0.0 to v1.1.0 🚀

Welcome to Easy Cache Manager v1.1.0! This update transforms our package from "complex for experts" to "smart for everyone." Here's how to upgrade and take advantage of the new features.

## 📦 Quick Upgrade

```yaml
dependencies:
  easy_cache_manager: ^1.1.0 # Updated from ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🎯 Migration Paths

### Option 1: Keep Your Existing Code (100% Backwards Compatible)

**No changes required!** All your existing v1.0.0 code will continue to work exactly as before.

### Option 2: Simplify with SimpleCacheManager (Recommended for Beginners)

If your current code looks complex, you can simplify it:

#### Before (v1.0.0):

```dart
final cacheManager = CacheManager(
  config: CacheConfig(
    maxSize: 100 * 1024 * 1024, // 100MB
    ttl: Duration(hours: 24),
    evictionPolicy: EvictionPolicy.lru(),
    storageAdapter: SqliteStorageAdapter(),
    // ... more configuration
  ),
);
await cacheManager.initialize();
```

#### After (v1.1.0 - Simple):

```dart
// Option A: Zero config
await SimpleCacheManager.init();
await SimpleCacheManager.save('key', data);
final data = await SimpleCacheManager.get('key');

// Option B: Auto config
final cache = await EasyCacheManager.auto();
await cache.set('key', data);
```

### Option 3: Smart Templates (Recommended for Specific Apps)

Replace complex configurations with smart templates:

#### Before:

```dart
final cacheManager = CacheManager(
  config: CacheConfig(
    maxSize: 500 * 1024 * 1024, // 500MB for e-commerce
    ttl: Duration(hours: 6), // Product data changes frequently
    evictionPolicy: EvictionPolicy.lfu(), // Frequently accessed products
    compressionEnabled: true, // Save bandwidth costs
    // ... lots more config
  ),
);
```

#### After:

```dart
// Auto-detects e-commerce needs and applies best practices
final cache = await EasyCacheManager.template(AppType.ecommerce);
```

## 🆕 New Features You Can Use

### 1. AI-Powered Configuration

```dart
// Let AI analyze your app and choose the perfect setup
final smartCache = await EasyCacheManager.smart(
  appType: AppType.social,
  expectedUsers: 10000,
  dataTypes: [DataType.images, DataType.json],
  platform: Platform.mobile,
  importance: CacheImportance.high,
);
```

### 2. Learning Resources (FREE)

- **[Clean Architecture Masterclass](docs/architecture/)** - Learn the patterns we use
- **[Beginner Guide](docs/beginners/)** - Start from zero
- **[Configuration Cookbook](docs/config/)** - Copy-paste solutions

### 3. Better Debugging

```dart
// New: Enhanced error messages
try {
  await cache.set('key', data);
} catch (e) {
  // Now gets clear, actionable error messages
  print(e); // "Cache storage full. Consider increasing maxSize or enabling compression."
}
```

## 🔧 Advanced Migration Scenarios

### If You Have Custom Configurations

Your existing custom configurations work perfectly. But now you can also:

```dart
// Start with a template, then customize
final cache = await EasyCacheManager.template(AppType.news)
  .copyWith(
    maxSize: 1000 * 1024 * 1024, // Override to 1GB
    customEvictionPolicy: MyCustomPolicy(),
  );
```

### If You Built Your Own Widgets

All existing widgets continue to work. New widgets are available:

```dart
// Your existing widgets work fine
CacheStatsWidget(cacheManager: myCache)

// New: Simpler widgets
SimpleCacheStatsWidget() // Uses SimpleCacheManager automatically
```

## 🎓 Learning Opportunities

### For Beginners

If you struggled with v1.0.0 complexity:

1. Read our [Beginner Guide](docs/beginners/)
2. Try SimpleCacheManager first
3. Gradually explore advanced features

### For Experts

If you want to understand our architecture:

1. Read our [Clean Architecture Masterclass](docs/architecture/)
2. Explore the [File Structure Guide](docs/structure/)
3. Contribute to the project!

## 🐛 Common Migration Issues

### Issue: "I don't know which template to use"

**Solution:** Use the interactive guide:

```dart
final cache = await EasyCacheManager.auto(); // Let AI decide
```

### Issue: "My app is unique, no template fits"

**Solution:** Start with the closest template, then customize:

```dart
final cache = await EasyCacheManager.template(AppType.productivity)
  .copyWith(
    maxSize: mySpecificSize,
    evictionPolicy: mySpecificPolicy,
  );
```

### Issue: "I want to learn but it's overwhelming"

**Solution:** Follow our structured learning path:

1. [Complete Beginner Guide](docs/beginners/) (30 min)
2. [Configuration Cookbook](docs/config/) (15 min)
3. [Architecture Masterclass](docs/architecture/) (2 hours)

## 🎉 Why Upgrade?

### Immediate Benefits

- ✅ Zero-config option available
- ✅ Better error messages
- ✅ Smart templates for instant setup
- ✅ Free premium education content

### Long-term Benefits

- 🚀 Your team learns industry best practices
- 💰 Save thousands on architecture courses
- 📈 Better app performance with smart defaults
- 🤝 Join a community focused on education

## 🆘 Need Help?

### Documentation

- [Beginner Guide](docs/beginners/) - Start here if you're new
- [Configuration Guide](docs/config/) - Choose the right setup
- [Architecture Guide](docs/architecture/) - Understand the patterns

### Examples

- [Simple Usage Examples](example/simple/) - Copy-paste solutions
- [Advanced Examples](example/advanced/) - Complex scenarios
- [Migration Examples](example/migration/) - Before/after comparisons

### Community

- GitHub Issues - Technical problems
- Discussions - Questions and tips
- Contributing Guide - Help improve the package

## 🎯 Next Steps

1. **Upgrade your dependencies** (`flutter pub get`)
2. **Keep your existing code** (works as-is)
3. **Try SimpleCacheManager** in a new feature
4. **Read the learning materials** at your own pace
5. **Share feedback** on what you'd like to see next

Remember: v1.1.0 doesn't force you to change anything. It just gives you better options when you're ready! 🎉
