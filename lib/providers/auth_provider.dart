import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthState {
  final bool isLoggedIn;
  final Map<String, dynamic>? user;

  AuthState({required this.isLoggedIn, this.user});
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  @override
  Future<AuthState> build() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return AuthState(isLoggedIn: false);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Authorization': 'Bearer $token'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      final res = await dio.get('/api/auth/mobile/me');
      return AuthState(
        isLoggedIn: true,
        user: res.data as Map<String, dynamic>?,
      );
    } catch (_) {
      return AuthState(isLoggedIn: true);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ));
      final res = await dio.post(
        '/api/auth/mobile/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      await _storage.write(
          key: 'access_token', value: data['accessToken'] as String?);
      await _storage.write(
          key: 'refresh_token', value: data['refreshToken'] as String?);
      state = AsyncValue.data(
        AuthState(
          isLoggedIn: true,
          user: data['user'] as Map<String, dynamic>?,
        ),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] ?? 'Login failed';
      state = AsyncValue.error(msg, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        final dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ));
        await dio.post('/api/auth/mobile/logout');
      } catch (_) {}
    }
    await _storage.deleteAll();
    state = AsyncValue.data(AuthState(isLoggedIn: false));
  }

  Map<String, dynamic>? get currentUser => state.valueOrNull?.user;
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final accessTokenProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return storage.read(key: 'access_token');
});

final dioProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        try {
          const storage = FlutterSecureStorage();
          final refreshToken = await storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            const String refreshBase = String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:3000',
            );
            final refreshDio = Dio(BaseOptions(baseUrl: refreshBase));
            final res = await refreshDio.post(
              '/api/auth/mobile/refresh',
              data: {'refreshToken': refreshToken},
            );
            final data = res.data as Map<String, dynamic>;
            await storage.write(
                key: 'access_token',
                value: data['accessToken'] as String?);
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';
            final retryRes = await refreshDio.fetch(opts);
            handler.resolve(retryRes);
            return;
          }
        } catch (_) {}
        await const FlutterSecureStorage().deleteAll();
      }
      handler.next(error);
    },
  ));
  return dio;
});
