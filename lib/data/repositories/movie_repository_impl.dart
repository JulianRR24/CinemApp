import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/daily_selection.dart';
import '../../domain/entities/interaction.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/supabase_local_datasource.dart';
import '../datasources/tmdb_remote_datasource.dart';
import '../models/daily_selection_model.dart';
import '../models/interaction_model.dart';
import '../models/movie_model.dart';
import '../models/person_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final TMDbRemoteDataSource remoteDataSource;
  final SupabaseLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    required int page,
    String? sortBy,
    String? withGenres,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    String? withOriginalLanguage,
  }) async {
    try {
      final remoteMovies = await remoteDataSource.discoverMovies(
        page: page,
        sortBy: sortBy,
        withGenres: withGenres,
        releaseDateGte: releaseDateGte,
        releaseDateLte: releaseDateLte,
        voteAverageGte: voteAverageGte,
        withOriginalLanguage: withOriginalLanguage,
      );
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      final remoteMovies = await remoteDataSource.searchMovies(query);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchMulti(String query) async {
    try {
      final results = await remoteDataSource.searchMulti(query);
      final searchResults = <SearchResult>[];

      for (final item in results) {
        final mediaType = item['media_type'];
        if (mediaType == 'movie') {
          searchResults.add(MovieSearchResult(MovieModel.fromJson(item)));
        } else if (mediaType == 'person') {
          searchResults.add(PersonSearchResult(PersonModel.fromJson(item)));
        }
      }
      return Right(searchResults);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetails(int movieId) async {
    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      return Right(movie);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Person>> getPersonDetails(int personId) async {
    try {
      final person = await remoteDataSource.getPersonDetails(personId);
      return Right(person);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DailySelection?>> getDailySelection(
    DateTime date,
    String profileId,
  ) async {
    try {
      // 1. Get IDs from local DB
      final row = await localDataSource.getDailySelection(date, profileId);

      if (row == null) {
        return const Right(null);
      }

      // 2. Fetch movies for these IDs
      final List<Movie> movies = [];
      for (final movieId in row.movieIds) {
        try {
          // We use getMovieDetails but it returns MovieDetailModel (which is a MovieData).
          // We can just use it as Movie.
          final movie = await remoteDataSource.getMovieDetails(movieId);
          movies.add(movie);
        } catch (e) {
          // Skip failed movie
        }
      }

      return Right(
        DailySelection(
          id: row.id,
          profileId: row.profileId,
          date: row.date,
          movies: movies,
        ),
      );
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveDailySelection(
    DailySelection selection,
  ) async {
    try {
      final model = DailySelectionModel(
        id: selection.id,
        profileId: selection.profileId,
        date: selection.date,
        movies: selection.movies,
      );
      await localDataSource.saveDailySelection(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Interaction>>> getUserInteractions(
    String profileId,
  ) async {
    try {
      final interactions = await localDataSource.getUserInteractions(profileId);
      return Right(interactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveInteraction(Interaction interaction) async {
    try {
      final model = InteractionModel(
        id: interaction.id,
        profileId: interaction.profileId,
        movieId: interaction.movieId,
        status: interaction.status,
        updatedAt: interaction.updatedAt,
      );
      await localDataSource.saveInteraction(model);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteInteraction(
    String profileId,
    int movieId,
  ) async {
    try {
      await localDataSource.deleteInteraction(profileId, movieId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}
