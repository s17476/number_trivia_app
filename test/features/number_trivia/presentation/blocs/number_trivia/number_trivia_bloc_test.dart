import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia_app/features/core/error/failures.dart';
import 'package:number_trivia_app/features/core/usecases/usecase.dart';
import 'package:number_trivia_app/features/core/utils/input_converter.dart';
import 'package:number_trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia_app/features/number_trivia/presentation/blocs/number_trivia/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {
  // @override
  // Future<Either<Failure, NumberTrivia>> call(Params params) async {
  //   return Right(NumberTrivia(number: params.number, text: 'test'));
  // }
}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUpAll(() {
    registerFallbackValue(const Params(number: 1));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockInputConverter = MockInputConverter();
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial state should be Empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const String tNumberString = '1';
    final tNumberParsed = 1;
    const NumberTrivia tNumberTrivia = NumberTrivia(text: 'test', number: 1);
    test(
      'should call InputConverter to validate and convert to an unsigned integer',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Right(tNumberParsed));
        when(
          () => mockGetConcreteNumberTrivia(any()),
        ).thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
        await untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        );
        // assert
        verify(
          () => mockInputConverter.stringToUnsignedInteger(tNumberString),
        );
      },
    );

    test(
      'should emit [Error] state when the input is invalid',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Left(InvalidInputFailure()));
        // assert
        expectLater(bloc.stream, emits(Error(message: INPUT_FAILURE_MESSAGE)));
        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
      },
    );

    test(
      'should get data from concrete usecase',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Right(tNumberParsed));
        when(
          () => mockGetConcreteNumberTrivia(any()),
        ).thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
        await untilCalled(
            () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
        // assert
        verify(
            () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data  is gotten succesfully',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Right(tNumberParsed));
        when(
          () => mockGetConcreteNumberTrivia(any()),
        ).thenAnswer((_) async => const Right(tNumberTrivia));
        // assert later
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when data fails',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Right(tNumberParsed));
        when(
          () => mockGetConcreteNumberTrivia(any()),
        ).thenAnswer((_) async => const Left(ServerFailure()));
        // assert later
        final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when proper message for the message for the error when getting data fails',
      () async {
        // arrange
        when(
          () => mockInputConverter.stringToUnsignedInteger(any()),
        ).thenReturn(Right(tNumberParsed));
        when(
          () => mockGetConcreteNumberTrivia(any()),
        ).thenAnswer((_) async => const Left(CacheFailure()));
        // assert later
        final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(number: tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    const NumberTrivia tNumberTrivia = NumberTrivia(text: 'test', number: 1);

    test(
      'should get data from the random usecase',
      () async {
        // arrange

        when(
          () => mockGetRandomNumberTrivia(any()),
        ).thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));
        // assert
        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data  is gotten succesfully',
      () async {
        // arrange
        when(
          () => mockGetRandomNumberTrivia(any()),
        ).thenAnswer((_) async => const Right(tNumberTrivia));
        // assert later
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when data fails',
      () async {
        // arrange
        when(
          () => mockGetRandomNumberTrivia(any()),
        ).thenAnswer((_) async => const Left(ServerFailure()));
        // assert later
        final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [Loading, Error] when proper message for the message for the error when getting data fails',
      () async {
        // arrange

        when(
          () => mockGetRandomNumberTrivia(any()),
        ).thenAnswer((_) async => const Left(CacheFailure()));
        // assert later
        final expected = [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );
  });
}
