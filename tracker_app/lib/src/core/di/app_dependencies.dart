import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/firebase_auth_repository.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
