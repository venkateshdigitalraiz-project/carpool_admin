import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable implements Exception {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server encounter an error. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed. Please check your internet.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error occurred.']);
}
