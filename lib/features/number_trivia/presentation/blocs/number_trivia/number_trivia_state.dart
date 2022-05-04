part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {
  const NumberTriviaState([this.properties = const []]);

  final List properties;

  @override
  List<Object> get props => [properties];
}

class Empty extends NumberTriviaState {}

class Loading extends NumberTriviaState {}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;
  Loaded({
    required this.trivia,
  }) : super([trivia]);
}

class Error extends NumberTriviaState {
  final String message;
  Error({
    required this.message,
  }) : super([message]);
}
