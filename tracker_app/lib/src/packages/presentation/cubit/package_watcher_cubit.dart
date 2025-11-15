import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:tracker_app/src/auth/domain/entities/app_user.dart';
import '../../domain/entities/package.dart';
import '../../domain/repositories/package_repository.dart';

part 'package_watcher_state.dart';

class PackageWatcherCubit extends Cubit<PackageWatcherState> {
  PackageWatcherCubit(this._repository)
    : super(const PackageWatcherState.initial());

  final PackageRepository _repository;
  StreamSubscription<List<Package>>? _subscription;

  Future<void> watchForUser(AppUser? user) async {
    await _subscription?.cancel();
    if (user == null) {
      emit(const PackageWatcherState.initial());
      return;
    }
    emit(const PackageWatcherState.loading());
    _subscription = _repository
        .watchPackagesForUser(user)
        .listen(
          (packages) => emit(PackageWatcherState.success(packages)),
          onError: (error) {
            emit(
              const PackageWatcherState.failure(
                'Error cargando paquetes, intenta nuevamente.',
              ),
            );
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
