part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent([this.numberString = '']);

  final String numberString;

  @override
  List<Object> get props => [numberString];
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String number;

  const GetTriviaForConcreteNumber({
    required this.number,
  }) : super(number);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
