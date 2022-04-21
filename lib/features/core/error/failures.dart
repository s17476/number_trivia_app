import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);
}

/// General failures
class ServerFailure extends Failure {
  final List properties;
  const ServerFailure({required this.properties}) : super(properties);

  @override
  List<Object?> get props => properties;
}

class CacheFailure extends Failure {
  final List properties;
  const CacheFailure({required this.properties}) : super(properties);

  @override
  List<Object?> get props => properties;
}
