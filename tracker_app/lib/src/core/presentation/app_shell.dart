import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TrackPro MVP')),
      body: const Center(
        child: Text(
          'Próximamente: login, asignaciones y mapa en vivo 🚚',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
