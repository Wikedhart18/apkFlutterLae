import 'package:flutter/material.dart';

import '../../auth/presentation/pages/login_page.dart';
import '../../auth/presentation/pages/register_page.dart';
import '../../packages/domain/entities/package.dart';
import '../presentation/app_shell.dart';
import '../presentation/map_detail_page.dart';

class AppRouter {
  static const splash = '/';
  static const dashboard = '/dashboard';
  static const login = '/login';
  static const register = '/register';
  static const mapDetail = '/map-detail';

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
      case mapDetail:
        return MaterialPageRoute<void>(
          builder: (_) =>
              MapDetailPage(package: settings.arguments! as Package),
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
