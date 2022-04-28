import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_app/features/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSource numberTriviaRemoteDataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(
    () {
      mockHttpClient = MockHttpClient();
      numberTriviaRemoteDataSource =
          NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    },
  );

  void setUpMockHttpClientFailure() {
    when(
      () => mockHttpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('Bad code', 404));
  }

  void setUpMockHttpClientSucces() {
    when(
      () => mockHttpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should preform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSucces();
        // act
        numberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NUmberTrivia when the response is 200',
      () async {
        // arrange
        setUpMockHttpClientSucces();
        // act
        final result =
            await numberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should throw ServerException when the response code is not 200',
      () async {
        // arrange
        setUpMockHttpClientFailure();
        // act
        final call = numberTriviaRemoteDataSource.getConcreteNumberTrivia;
        // assert
        expect(
            () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should preform a GET request on a URL with number 
      being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSucces();
        // act
        numberTriviaRemoteDataSource.getRandomNumberTrivia();
        // assert
        verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response is 200',
      () async {
        // arrange
        setUpMockHttpClientSucces();
        // act
        final result =
            await numberTriviaRemoteDataSource.getRandomNumberTrivia();
        // assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should throw ServerException when the response code is not 200',
      () async {
        // arrange
        setUpMockHttpClientFailure();
        // act
        final call = numberTriviaRemoteDataSource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });
}
