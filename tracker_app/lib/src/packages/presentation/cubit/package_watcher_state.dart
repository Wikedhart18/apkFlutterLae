part of 'package_watcher_cubit.dart';

enum PackageWatcherStatus { initial, loading, success, failure }

class PackageWatcherState extends Equatable {
  const PackageWatcherState._({
    required this.status,
    this.packages = const [],
    this.message,
  });

  const PackageWatcherState.initial()
    : this._(status: PackageWatcherStatus.initial);

  const PackageWatcherState.loading()
    : this._(status: PackageWatcherStatus.loading);

  const PackageWatcherState.success(List<Package> packages)
    : this._(status: PackageWatcherStatus.success, packages: packages);

  const PackageWatcherState.failure(String message)
    : this._(status: PackageWatcherStatus.failure, message: message);

  final PackageWatcherStatus status;
  final List<Package> packages;
  final String? message;

  @override
  List<Object?> get props => [status, packages, message];
}
