import 'package:flutter/material.dart';

import '../presentation/app_shell.dart';

class AppRouter {
  static const splash = '/';
  static const dashboard = '/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
      case splash:
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );
    }
  }
}
