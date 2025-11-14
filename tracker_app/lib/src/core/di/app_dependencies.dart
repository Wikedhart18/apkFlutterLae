import 'package:flutter/material.dart';

/// Contenedor de dependencias globales. Más adelante envolveremos
/// `child` con MultiRepositoryProvider/MultiBlocProvider cuando
/// existan repos y blocs compartidos. Por ahora devolvemos el
/// widget directamente para evitar asserts del paquete `nested`.
class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
