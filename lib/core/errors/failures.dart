import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation failed', super.statusCode});
}

class SyncFailure extends Failure {
  const SyncFailure({super.message = 'Sync failed', super.statusCode});
}
