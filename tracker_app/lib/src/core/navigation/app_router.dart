import 'package:flutter/material.dart';

import '../../auth/presentation/pages/auth_gate.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../presentation/app_shell.dart';

class AppRouter {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const login = '/login';
  static const register = '/register';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute<void>(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case splash:
        return MaterialPageRoute<void>(
          builder: (_) => const AuthGate(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
      case splash:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
    }
  }
}
