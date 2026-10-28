import 'package:equatable/equatable.dart';

/// Base abstract class for Clean Architecture Use Cases.
/// [Type] is the return type of the usecase.
/// [Params] is the parameter required for the usecase execution.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Helper class when a UseCase does not require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
