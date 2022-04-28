import 'dart:convert';

import 'package:number_trivia_app/features/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  ///Gets the cached [NumberTriviaModel] wich was gotten the last time
  ///the user had an internet connection.
  ///
  ///Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences dataSource;

  NumberTriviaLocalDataSourceImpl({
    required this.dataSource,
  });

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = dataSource.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    }
    throw CacheException();
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    return dataSource.setString(
      CACHED_NUMBER_TRIVIA,
      json.encode(triviaToCache.toJson()),
    );
  }
}
