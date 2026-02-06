# Flutter Riverpod 2025 Best Practices

Riverpod 상태 관리의 2025년 모범 사례 가이드.

## 핵심 원칙

1. **코드 생성 강력 권장** - `@riverpod` 어노테이션과 `riverpod_generator` 사용
2. **AsyncNotifierProvider 우선** - 비동기 상태에는 FutureProvider/StreamProvider 대신 AsyncNotifierProvider 사용
3. **AutoDispose 기본** - 코드 생성 시 자동으로 auto-dispose 적용
4. **Repository 패턴** - 데이터 레이어와 상태 관리 분리
5. **성능 우선** - `select()`로 리빌드 최적화

## Provider 선택 가이드

### 의사결정 트리

```
어떤 종류의 상태인가?
├─ 불변/계산된 값 → Provider (@riverpod 함수)
├─ 단순 동기 상태 → NotifierProvider (@riverpod 클래스)
├─ 비동기 데이터 + 뮤테이션 (권장) → AsyncNotifierProvider (@riverpod 클래스, Future 반환)
└─ 실시간 스트림만 필요 → StreamProvider (@riverpod 함수, Stream 반환)
```

### 불변/계산된 값 - Provider

```dart
@riverpod
String apiKey(Ref ref) => 'YOUR_API_KEY';

@riverpod
int totalPrice(Ref ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold(0, (sum, item) => sum + item.price);
}
```

### 단순 동기 상태 - NotifierProvider

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state = max(0, state - 1);
}
```

### 비동기 데이터 + 뮤테이션 (권장) - AsyncNotifierProvider

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final repo = ref.watch(todoRepositoryProvider);
    return repo.fetchTodos();
  }

  Future<void> addTodo(String title) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(todoRepositoryProvider);
      await repo.createTodo(title);
      return repo.fetchTodos();
    });
  }

  // 낙관적 업데이트 패턴
  Future<void> deleteTodo(String id) async {
    state = AsyncData(state.value!.where((t) => t.id != id).toList());

    try {
      await ref.read(todoRepositoryProvider).deleteTodo(id);
    } catch (e) {
      ref.invalidateSelf(); // 에러 시 롤백
    }
  }
}
```

### 실시간 스트림 - StreamProvider

```dart
@riverpod
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}
```

## 코드 생성 설정

### 의존성 (pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.0
```

### 파일 템플릿

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filename.g.dart'; // 필수

@riverpod
class MyProvider extends _$MyProvider {
  @override
  Future<Data> build() async => fetchData();
}
```

### 제너레이터 실행

```bash
# 개발 중 워치 모드 (권장)
dart run build_runner watch -d

# 일회성 생성
dart run build_runner build --delete-conflicting-outputs
```

## 성능 최적화 패턴

### ref.select()로 특정 필드만 구독

```dart
// ❌ BAD: product의 모든 변경에 리빌드
final product = ref.watch(productProvider);
return Text('${product.price}');

// ✅ GOOD: price 변경 시에만 리빌드
final price = ref.watch(productProvider.select((p) => p.price));
return Text('$price');
```

### ref 메서드 비교

| 메서드 | 용도 | 사용 위치 |
|--------|------|-----------|
| `ref.watch()` | 변경 구독, 리빌드 트리거 | build 메서드 내 |
| `ref.select()` | 특정 속성만 구독 (리빌드 최적화) | build 메서드 내 |
| `ref.read()` | 일회성 읽기, 구독 없음 | 이벤트 핸들러 (onPressed 등) |
| `ref.listen()` | 사이드 이펙트 (네비게이션, 스낵바) | build 메서드 내 |

```dart
// ref.watch() - build 내에서 상태 구독
@override
Widget build(BuildContext context, WidgetRef ref) {
  final todos = ref.watch(todoListProvider);
  return ListView(...);
}

// ref.select() - 특정 속성만 구독
final count = ref.watch(
  todoListProvider.select((todos) => todos.length),
);

// ref.read() - 이벤트 핸들러에서 일회성 읽기
onPressed: () {
  ref.read(todoListProvider.notifier).addTodo('New task');
}
// ❌ NEVER: build에서 read() 사용 금지 (리빌드 안됨!)

// ref.listen() - 사이드 이펙트
ref.listen<AsyncValue<List<Todo>>>(
  todoListProvider,
  (previous, next) {
    next.whenOrNull(
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );
  },
);
```

### 루프 내 watch 금지

```dart
// ❌ BAD: 성능 문제 발생
ListView.builder(
  itemBuilder: (context, index) {
    final todo = ref.watch(todoProvider(ids[index])); // 금지!
    return ListTile(...);
  },
);

// ✅ GOOD: 항목별 별도 위젯으로 분리
class TodoItem extends ConsumerWidget {
  const TodoItem({required this.todoId});
  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(todoProvider(todoId));
    return ListTile(title: Text(todo.title));
  }
}
```

### 파생 Provider 생성

```dart
@riverpod
List<Todo> filteredSortedTodos(Ref ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(filterProvider);
  final sortOrder = ref.watch(sortOrderProvider);

  final filtered = todos.where((t) => t.matches(filter)).toList();
  return filtered..sort(sortOrder.comparator);
}
```

## Repository 패턴 아키텍처

### 3계층 구조

**1. Data Layer - Repository**:

```dart
@riverpod
TodoRepository todoRepository(Ref ref) {
  return TodoRepository(dio: ref.watch(dioProvider));
}

class TodoRepository {
  TodoRepository({required this.dio});
  final Dio dio;

  Future<List<Todo>> fetchTodos() async {
    final response = await dio.get('/todos');
    return (response.data as List)
        .map((json) => Todo.fromJson(json))
        .toList();
  }

  Future<Todo> createTodo(String title) async {
    final response = await dio.post('/todos', data: {'title': title});
    return Todo.fromJson(response.data);
  }

  Future<void> deleteTodo(String id) async {
    await dio.delete('/todos/$id');
  }
}
```

**2. Application Layer - State Management**:

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.fetchTodos();
  }

  Future<void> addTodo(String title) async {
    final repository = ref.read(todoRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.createTodo(title);
      return repository.fetchTodos();
    });
  }
}
```

**3. Presentation Layer - UI**:

```dart
class TodoListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: todosAsync.when(
        data: (todos) => ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) => TodoTile(todos[index]),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => ErrorView(error: error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 의존성 주입

```dart
// 서비스
@riverpod
Dio dio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  dio.interceptors.add(LogInterceptor());
  return dio;
}

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    dio: ref.watch(dioProvider),
    storage: ref.watch(sharedPreferencesProvider).value!,
  );
}

// Repository는 서비스에 의존
@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(
    dio: ref.watch(dioProvider),
    authService: ref.watch(authServiceProvider),
  );
}

// 상태 Provider는 Repository에 의존
@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<User?> build() async {
    final authService = ref.watch(authServiceProvider);
    final userId = await authService.getCurrentUserId();

    if (userId == null) return null;

    final repository = ref.watch(userRepositoryProvider);
    return repository.fetchUser(userId);
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    ref.invalidateSelf();
  }
}
```

## Family Providers (파라미터화)

코드 생성 시 파라미터를 추가하면 자동으로 Family가 됨:

```dart
// 단순 Family Provider
@riverpod
Future<User> user(Ref ref, String id) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/users/$id');
  return User.fromJson(response.data);
}

// 사용
final user = ref.watch(userProvider('123'));

// AsyncNotifier Family
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String id) async {
    final repo = ref.watch(userRepositoryProvider);
    return repo.fetchUser(id);
  }

  Future<void> updateName(String newName) async {
    final userId = arg; // 'arg'로 파라미터 접근
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateUser(
        userId,
        name: newName,
      );
      return ref.read(userRepositoryProvider).fetchUser(userId);
    });
  }
}

// 복합 파라미터는 equality 구현 필요
class UserFilter {
  const UserFilter({required this.role, required this.active});
  final String role;
  final bool active;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFilter &&
          role == other.role &&
          active == other.active;

  @override
  int get hashCode => Object.hash(role, active);
}

@riverpod
Future<List<User>> filteredUsers(Ref ref, UserFilter filter) async {
  return fetchUsers(filter);
}
```

## AutoDispose와 캐싱

코드 생성 시 Provider는 **기본적으로 auto-dispose**:

```dart
// 기본: 리스너 없으면 auto-dispose
@riverpod
Future<String> data(Ref ref) async => fetchData();

// 영구 캐싱 (keepAlive)
@Riverpod(keepAlive: true)
Future<Config> config(Ref ref) async => loadConfig();

// 조건부 keepAlive - 성공 시 캐싱
@riverpod
Future<String> cachedData(Ref ref) async {
  final data = await fetchData();
  ref.keepAlive(); // 이 결과를 영구 캐싱
  return data;
}

// 시간 제한 캐싱 (5분)
@riverpod
Future<String> timedCache(Ref ref) async {
  final data = await fetchData();
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);
  return data;
}

// 수동 정리 - 리소스 해제
@riverpod
Stream<int> websocket(Ref ref) {
  final client = WebSocketClient();

  ref.onDispose(() {
    client.close(); // Provider dispose 시 정리
  });

  return client.stream;
}
```

## 에러 처리

### 포괄적 에러 처리

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    try {
      final repository = ref.watch(todoRepositoryProvider);
      return await repository.fetchTodos();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        ref.read(authServiceProvider).logout();
        throw UnauthorizedException();
      }
      throw NetworkException(e.message);
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }

  Future<void> addTodo(String title) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(todoRepositoryProvider);
      await repository.createTodo(title);
      return repository.fetchTodos();
    });
  }
}
```

### UI 에러 처리

```dart
// .when() 사용
todosAsync.when(
  data: (todos) => ListView.builder(...),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stack) {
    if (error is NetworkException) {
      return ErrorView(
        message: 'Network error. Check your connection.',
        onRetry: () => ref.invalidate(todoListProvider),
      );
    }
    if (error is UnauthorizedException) {
      return const ErrorView(message: 'Please log in again.');
    }
    return ErrorView(message: 'Error: $error');
  },
);

// listen으로 에러 사이드 이펙트
ref.listen<AsyncValue<List<Todo>>>(
  todoListProvider,
  (previous, next) {
    next.whenOrNull(
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  },
);
```

## 테스트

### Provider 테스트

```dart
test('TodoList fetches todos correctly', () async {
  final container = ProviderContainer.test(
    overrides: [
      todoRepositoryProvider.overrideWithValue(MockTodoRepository()),
    ],
  );

  final todos = await container.read(todoListProvider.future);

  expect(todos.length, 2);
  expect(todos[0].title, 'Test Todo 1');
});

test('TodoList adds todo correctly', () async {
  final mockRepo = MockTodoRepository();
  final container = ProviderContainer.test(
    overrides: [
      todoRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );

  await container.read(todoListProvider.notifier).addTodo('New Todo');

  verify(() => mockRepo.createTodo('New Todo')).called(1);
});
```

### 위젯 테스트

```dart
testWidgets('TodoListScreen displays todos', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todoRepositoryProvider.overrideWithValue(MockTodoRepository()),
      ],
      child: const MaterialApp(home: TodoListScreen()),
    ),
  );

  await tester.pumpAndSettle();

  expect(find.text('Test Todo 1'), findsOneWidget);
  expect(find.text('Test Todo 2'), findsOneWidget);
});
```

## 흔한 안티패턴

### 성능 함정

```dart
// ❌ 리빌드 회피를 위해 ref.read() 사용 → 리빌드 안됨!
final todos = ref.read(todoListProvider);

// ✅ ref.watch() 또는 ref.select() 사용
final count = ref.watch(
  todoListProvider.select((todos) => todos.length),
);
```

### 메모리 누수

```dart
// ❌ 리소스 미해제
@riverpod
Stream<int> badWebsocket(Ref ref) {
  final client = WebSocketClient();
  return client.stream; // 닫히지 않음!
}

// ✅ 리소스 해제
@riverpod
Stream<int> goodWebsocket(Ref ref) {
  final client = WebSocketClient();
  ref.onDispose(() => client.close());
  return client.stream;
}
```

### 다중 진실 소스

```dart
// ❌ BAD: 어느 것이 진실 소스인가?
class BadWidget extends StatefulWidget {
  int localCount = 0; // 로컬 상태

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerCount = ref.watch(counterProvider); // Provider 상태
    return Text('$localCount vs $providerCount'); // 혼란!
  }
}

// ✅ GOOD: 단일 진실 소스
class GoodWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### 의존 Provider 무효화 누락

```dart
// ❌ BAD
Future<void> logout() async {
  state = null;
  // 다른 Provider에 이전 사용자 데이터 잔존!
}

// ✅ GOOD: 의존 Provider 무효화
Future<void> logout() async {
  state = null;
  ref.invalidate(userProfileProvider);
  ref.invalidate(userSettingsProvider);
  ref.invalidate(userNotificationsProvider);
}

// ✅ BETTER: Provider가 auth를 watch하도록 설계
@riverpod
Future<UserProfile> userProfile(Ref ref) async {
  final user = ref.watch(authProvider);
  if (user == null) throw UnauthenticatedException();
  return fetchUserProfile(user.id); // user 변경 시 자동 재요청
}
```
