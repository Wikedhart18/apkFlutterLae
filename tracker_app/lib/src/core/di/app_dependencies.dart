import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/firebase_auth_repository.dart';
import '../../auth/data/firebase_user_repository.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/domain/repositories/user_repository.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../packages/data/firebase_package_repository.dart';
import '../../packages/domain/repositories/package_repository.dart';
import '../../packages/presentation/cubit/package_watcher_cubit.dart';

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
        RepositoryProvider<UserRepository>(
          create: (_) => FirebaseUserRepository(),
        ),
        RepositoryProvider<PackageRepository>(
          create: (_) => FirebasePackageRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<PackageWatcherCubit>(
            create: (context) =>
                PackageWatcherCubit(context.read<PackageRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
