import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

// Provider for SharedPreferences instance (async)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  // We will pass the SharedPreferences instance directly if needed, 
  // but ApiClient can also fetch it asynchronously.
  return ApiClient();
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
  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final otrId = prefs.getString('otr_id');
    final fullName = prefs.getString('full_name');
    
    if (token != null && otrId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        otrId: otrId,
        fullName: fullName,
      );
    }
  }

  Future<void> login(String token, String otrId, String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('otr_id', otrId);
    await prefs.setString('full_name', fullName);
    
    state = state.copyWith(
      isAuthenticated: true,
      otrId: otrId,
      fullName: fullName,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState(isAuthenticated: false);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
