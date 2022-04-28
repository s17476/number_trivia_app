import 'dart:convert';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia_app/features/core/error/exceptions.dart';
import 'package:number_trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSource numberTriviaLocalDataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSource =
        NumberTriviaLocalDataSourceImpl(dataSource: mockSharedPreferences);
    SharedPreferences.setMockInitialValues({});
  });

  group('getLastNumberTrivia', () {
    final tnumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
      'should return number NumberTriviamodel from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await numberTriviaLocalDataSource.getLastNumberTrivia();
        // assert
        verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tnumberTriviaModel));
      },
    );

    test(
      'should throw CacheException when there is no cached value',
      () async {
        // arrange
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);
        // act
        final call = numberTriviaLocalDataSource.getLastNumberTrivia;
        // assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');

    test(
        'should store tNumberTriviaModel in SharedPreferences to cache the data',
        () async {
      // arrange
      SharedPreferences.setMockInitialValues({});
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      numberTriviaLocalDataSource =
          NumberTriviaLocalDataSourceImpl(dataSource: sharedPreferences);
      // act
      await numberTriviaLocalDataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedNumberTriviaModel =
          await numberTriviaLocalDataSource.getLastNumberTrivia();

      expect(expectedNumberTriviaModel, tNumberTriviaModel);
    });
  });
}
