# 🏗️ Clean Architecture มาสเตอร์คลาส

> **🎓 เรียนรู้ Clean Architecture แบบจัดเต็ม**
>
> ไม่ใช่แค่ใช้ package นี้ แต่คุณจะได้ความรู้ Clean Architecture ระดับมืออาชีพ ที่ปกติต้องจ่ายหลักหมื่นไปเรียน!

## 📚 หลักสูตรฟรี: Clean Architecture for Flutter

### 🎯 Module 1: ทำไมต้อง Clean Architecture?

#### ปัญหาของสถาปัตยกรรมแบบเดิม

```dart
// ❌ แบบเดิม - ทุกอย่างปนกัน
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User> users = [];

  Future<void> loadUsers() async {
    // UI ผูกติดกับ API โดยตรง
    final response = await http.get('https://api.example.com/users');
    final data = json.decode(response.body);
    setState(() {
      users = data.map<User>((json) => User.fromJson(json)).toList();
    });
  }

  // การ cache ผูกติดกับ UI
  Future<void> cacheUsers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('users', json.encode(users));
  }
}
```

#### ปัญหาที่เจอ:

- 🔧 แก้ไขยาก: เปลี่ยน API ต้องแก้ UI
- 🧪 เทสยาก: ไม่สามารถ test แยกส่วนได้
- 🔄 Reuse ไม่ได้: Logic ผูกติดกับ UI
- 📱 Platform ต่างกันทำงานไม่ได้

### 🏗️ Module 2: Clean Architecture คือไร?

```
┌─────────────────────────────────────────┐
│              🎯 DOMAIN LAYER            │  ← Business Logic ที่แท้จริง
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │Entities │  │UseCases │  │  Repos  │  │
│  │         │  │         │  │(Abstract)│  │
│  └─────────┘  └─────────┘  └─────────┘  │
└─────────────────────────────────────────┘
           ↑                    ↑
           │                    │
┌─────────────────────┐  ┌─────────────────────┐
│   📱 PRESENTATION   │  │     💾 DATA        │
│                     │  │                     │
│ ┌─────┐ ┌─────────┐ │  │ ┌───────┐ ┌───────┐ │
│ │Pages│ │Providers│ │  │ │ Repos │ │Sources│ │
│ │     │ │         │ │  │ │(Impl) │ │       │ │
│ └─────┘ └─────────┘ │  │ └───────┘ └───────┘ │
└─────────────────────┘  └─────────────────────┘
```

### 🎯 Module 3: Domain Layer - หัวใจของระบบ

#### 3.1 Entities (โครงสร้างข้อมูลหลัก)

```dart
// 📄 lib/src/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // Business Rules ใส่ไว้ใน Entity
  bool get isActive => DateTime.now().difference(createdAt).inDays <= 365;
  String get displayName => name.isEmpty ? email : name;
}
```

#### 3.2 Use Cases (กฎธุรกิจ)

```dart
// 📄 lib/src/domain/usecases/get_user_usecase.dart
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase({required this.repository});

  Future<Either<Failure, User>> call(String userId) async {
    try {
      // ลำดับการทำงานของธุรกิจ

      // 1. ตรวจสอบ input
      if (userId.isEmpty) {
        return Left(ValidationFailure('User ID cannot be empty'));
      }

      // 2. ลองหาจาก cache ก่อน
      final cachedUser = await repository.getCachedUser(userId);
      if (cachedUser != null && cachedUser.isActive) {
        return Right(cachedUser);
      }

      // 3. ถ้าไม่มี cache ให้ดึงจากเซิร์ฟเวอร์
      final user = await repository.getUserFromRemote(userId);

      // 4. เก็บ cache สำหรับครั้งหน้า
      await repository.cacheUser(user);

      return Right(user);

    } catch (e) {
      return Left(ServerFailure('Failed to get user: $e'));
    }
  }
}
```

#### 3.3 Repository Contracts (สัญญา)

```dart
// 📄 lib/src/domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<User?> getCachedUser(String userId);
  Future<User> getUserFromRemote(String userId);
  Future<void> cacheUser(User user);
  Future<List<User>> getAllUsers();
  Future<void> deleteUser(String userId);
}
```

### 💾 Module 4: Data Layer - การจัดการข้อมูล

#### 4.1 Repository Implementation

```dart
// 📄 lib/src/data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<User?> getCachedUser(String userId) async {
    try {
      final userModel = await localDataSource.getCachedUser(userId);
      return userModel?.toEntity(); // Convert Model to Entity
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> getUserFromRemote(String userId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkFailure('No internet connection');
    }

    final userModel = await remoteDataSource.getUser(userId);
    return userModel.toEntity();
  }

  @override
  Future<void> cacheUser(User user) async {
    final userModel = UserModel.fromEntity(user);
    await localDataSource.cacheUser(userModel);
  }
}
```

#### 4.2 Data Sources

```dart
// 📄 lib/src/data/datasources/user_local_data_source.dart
abstract class UserLocalDataSource {
  Future<UserModel?> getCachedUser(String userId);
  Future<void> cacheUser(UserModel user);
  Future<void> deleteUser(String userId);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final CacheManager cacheManager;

  UserLocalDataSourceImpl({required this.cacheManager});

  @override
  Future<UserModel?> getCachedUser(String userId) async {
    try {
      final jsonData = await cacheManager.getJson('user_$userId');
      if (jsonData != null) {
        return UserModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw CacheFailure('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await cacheManager.storeJson(
        'user_${user.id}',
        user.toJson(),
        maxAge: Duration(hours: 24),
      );
    } catch (e) {
      throw CacheFailure('Failed to cache user: $e');
    }
  }
}
```

### 📱 Module 5: Presentation Layer - UI และ State Management

#### 5.1 Providers (State Management)

```dart
// 📄 lib/src/presentation/providers/user_provider.dart
class UserProvider extends ChangeNotifier {
  final GetUserUseCase getUserUseCase;

  UserProvider({required this.getUserUseCase});

  // State
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _currentUser != null;

  // Actions
  Future<void> loadUser(String userId) async {
    _setLoading(true);

    final result = await getUserUseCase.call(userId);

    result.fold(
      (failure) => _setError(failure.message),
      (user) => _setUser(user),
    );

    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setUser(User user) {
    _currentUser = user;
    _errorMessage = null;
  }

  void _setError(String error) {
    _currentUser = null;
    _errorMessage = error;
  }
}
```

#### 5.2 UI Pages

```dart
// 📄 lib/src/presentation/pages/user_page.dart
class UserPage extends StatelessWidget {
  final String userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (userProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(userProvider.errorMessage!),
                  ElevatedButton(
                    onPressed: () => userProvider.loadUser(userId),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = userProvider.currentUser;
          if (user != null) {
            return UserProfile(user: user);
          }

          return Center(child: Text('No user found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<UserProvider>().loadUser(userId),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

### 🔧 Module 6: Dependency Injection

```dart
// 📄 lib/src/injection_container.dart
final getIt = GetIt.instance;

Future<void> init() async {
  // Use Cases
  getIt.registerLazySingleton(() => GetUserUseCase(repository: getIt()));

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      localDataSource: getIt(),
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data Sources
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(cacheManager: getIt()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(httpClient: getIt()),
  );

  // External
  getIt.registerLazySingleton(() => CacheManager(
    config: CacheConfig.standard(),
  ));

  getIt.registerLazySingleton(() => http.Client());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}
```

## 🎓 สรุป: ประโยชน์ของ Clean Architecture

### ✅ **ข้อดี**

1. **🔧 แก้ไขง่าย**: เปลี่ยน API ไม่กระทบ UI
2. **🧪 เทสได้ทุกส่วน**: แยกส่วนชัดเจน
3. **🔄 Reuse ได้**: Business Logic ไม่ผูกกับ UI
4. **📱 Cross-platform**: Domain Layer ใช้ได้ทุกแพลตฟอร์ม
5. **👥 ทีมใหญ่ทำงานร่วมกันได้**: แยกหน้าที่ชัดเจน
6. **🚀 Scale ได้**: เพิ่มฟีเจอร์ไม่กระทบของเดิม

### 📊 เปรียบเทียบ

| หัวข้อ              | แบบเดิม | Clean Architecture |
| ------------------- | ------- | ------------------ |
| **Coupling**        | สูง     | ต่ำ                |
| **Testability**     | ยาก     | ง่าย               |
| **Maintainability** | ยาก     | ง่าย               |
| **Team Work**       | ยาก     | ง่าย               |
| **Learning Curve**  | ต่ำ     | สูง (แต่คุ้มค่า)   |

### 🎯 **เมื่อไหร่ควรใช้**

- ✅ แอปใหญ่ (มากกว่า 20 screens)
- ✅ ทีมใหญ่ (มากกว่า 3 คน)
- ✅ โปรเจกต์ long-term
- ✅ ต้อง maintainable
- ❌ Prototype/MVP แบบเร็วๆ
- ❌ แอปเล็กๆ ชั่วคราว

> 💡 **คำแนะนำ**: เริ่มจากแบบง่าย แล้วค่อยๆ refactor เป็น Clean Architecture เมื่อแอปเติบโต

## 📚 แหล่งเรียนรู้เพิ่มเติม

- 📖 [Uncle Bob's Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- 🎥 [Flutter Clean Architecture Course](https://resocoder.com/flutter-clean-architecture-tdd/)
- 💻 [Our Complete Example App](../example/)
- 🔧 [Configuration Guide](../config/)

---

_🎓 ตอนนี้คุณพร้อมที่จะเขียน Clean Architecture แบบมืออาชีพแล้ว! ไม่ว่าจะใช้ package นี้หรือไม่ คุณก็ได้ความรู้ที่มีค่าไปแล้ว_
