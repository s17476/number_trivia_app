import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia_app/features/core/error/failures.dart';
import 'package:number_trivia_app/features/core/usecases/usecase.dart';

import 'package:number_trivia_app/features/core/utils/input_converter.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server failure';
const String CACHE_FAILURE_MESSAGE = 'Cache failure';
const String INPUT_FAILURE_MESSAGE =
    'Invalid input - number must be a positive or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final Either inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      await inputEither.fold(
        (failure) async => emit(Error(message: INPUT_FAILURE_MESSAGE)),
        (integer) async {
          emit(Loading());
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));
          _eitherLoadedOrFailure(failureOrTrivia, emit);
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(Loading());
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      _eitherLoadedOrFailure(failureOrTrivia, emit);
    });
  }

  void _eitherLoadedOrFailure(Either<Failure, NumberTrivia> failureOrTrivia,
      Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold(
      (failure) => emit(Error(
        message: _mapFailureToMessage(failure),
      )),
      (trivia) {
        emit(Loaded(trivia: trivia));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
