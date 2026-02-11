import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/errors/exceptions.dart';
import '../models/movie_model.dart';

abstract class TMDbRemoteDataSource {
  Future<List<MovieModel>> discoverMovies({
    required int page,
    String? sortBy,
    String? withGenres,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    String? withOriginalLanguage,
  });
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> getMovieDetails(int movieId);
}

class TMDbRemoteDataSourceImpl implements TMDbRemoteDataSource {
  final http.Client client;

  TMDbRemoteDataSourceImpl({required this.client});

  final String _baseUrl = 'https://api.themoviedb.org/3';
  String get _readToken => dotenv.env['TMDB_READ_TOKEN'] ?? '';

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_readToken',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<MovieModel>> discoverMovies({
    required int page,
    String? sortBy,
    String? withGenres,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    String? withOriginalLanguage,
  }) async {
    final queryParams = {
      'language': 'es-ES',
      'page': page.toString(),
      'sort_by': sortBy ?? 'popularity.desc',
      'include_adult': 'false',
    };

    if (withGenres != null) {
      queryParams['with_genres'] = withGenres;
    }
    if (releaseDateGte != null) {
      queryParams['primary_release_date.gte'] = releaseDateGte;
    }
    if (releaseDateLte != null) {
      queryParams['primary_release_date.lte'] = releaseDateLte;
    }
    if (voteAverageGte != null) {
      queryParams['vote_average.gte'] = voteAverageGte.toString();
    }
    if (withOriginalLanguage != null) {
      queryParams['with_original_language'] = withOriginalLanguage;
    }

    final uri = Uri.parse(
      '$_baseUrl/discover/movie',
    ).replace(queryParameters: queryParams);

    final response = await client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/search/movie?language=es-ES&query=$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((e) => MovieModel.fromJson(e)).toList();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/movie/$movieId?language=es-ES'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MovieModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
