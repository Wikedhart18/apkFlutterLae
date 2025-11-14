import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/domain/entities/app_user.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackPro MVP v1.0.0'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hola ${user?.displayName ?? user?.email ?? 'usuario'} 👋'),
            const SizedBox(height: 16),
            const Text(
              'Próximamente: login, asignaciones y mapa en vivo 🚚',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
