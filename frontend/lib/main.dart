import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/otr_registration_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/application_wizard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: UniScholarApp(),
    ),
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/student-login',
        builder: (context, state) => const StudentLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => OtrRegistrationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/apply',
        builder: (context, state) {
          final schemeName = state.extra as String? ?? 'Scholarship Application';
          return ApplicationWizardScreen(schemeName: schemeName);
        },
      ),
    ],
  );
});

class UniScholarApp extends ConsumerWidget {
  const UniScholarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'UniScholar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // OFFICIAL NSP COLOR PALETTE
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A1010), // Logo Deep Maroon
          primary: const Color(0xFF4A1010), // Logo Deep Maroon
          secondary: const Color(0xFFB38031), // Logo Gold
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFCF9F2), // Logo Cream Background
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.black45,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          elevation: 2,
        ),
      ),
      routerConfig: router,
    );
  }
}
