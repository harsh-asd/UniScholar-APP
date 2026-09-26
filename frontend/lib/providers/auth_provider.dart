import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';

// Provider for Flutter Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider for API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

// Auth State Class
class AuthState {
  final bool isAuthenticated;
  final String? otrId;
  final String? fullName;

  AuthState({this.isAuthenticated = false, this.otrId, this.fullName});

  AuthState copyWith({bool? isAuthenticated, String? otrId, String? fullName}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      otrId: otrId ?? this.otrId,
      fullName: fullName ?? this.fullName,
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FlutterSecureStorage secureStorage;

  AuthNotifier(this.secureStorage) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await secureStorage.read(key: 'jwt_token');
    final otrId = await secureStorage.read(key: 'otr_id');
    final fullName = await secureStorage.read(key: 'full_name');
    
    if (token != null && otrId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        otrId: otrId,
        fullName: fullName,
      );
    }
  }

  Future<void> login(String token, String otrId, String fullName) async {
    await secureStorage.write(key: 'jwt_token', value: token);
    await secureStorage.write(key: 'otr_id', value: otrId);
    await secureStorage.write(key: 'full_name', value: fullName);
    
    state = state.copyWith(
      isAuthenticated: true,
      otrId: otrId,
      fullName: fullName,
    );
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
    state = AuthState(isAuthenticated: false);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage);
});
