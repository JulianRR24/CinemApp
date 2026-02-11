import 'package:dartz/dartz.dart';
import '../repositories/movie_repository.dart';
import '../entities/daily_selection.dart';
import '../entities/interaction.dart';
import '../../core/errors/failures.dart';

class GetDailySelection {
  final MovieRepository repository;

  GetDailySelection(this.repository);

  /// This usecase orchestrates the logic:
  /// 1. Check DB for today's selection
  /// 2. If exists AND has >= 10 movies, return it
  /// 3. If not, fetch from TMDB, filter, select random 10, save/overwrite to DB, return it
  Future<Either<Failure, DailySelection>> call(String profileId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Check DB
    final dbResult = await repository.getDailySelection(today, profileId);

    return dbResult.fold((failure) => Left(failure), (selection) async {
      // Enforce 10 movies. If less, regenerate.
      if (selection != null && selection.movies.length >= 10) {
        return Right(selection);
      } else {
        // 2. Generate new selection (force refresh if existing is < 10)
        return _generateNewSelection(profileId, today);
      }
    });
  }

  Future<Either<Failure, DailySelection>> _generateNewSelection(
    String profileId,
    DateTime date,
  ) async {
    // Get interactions to filter
    final interactionsResult = await repository.getUserInteractions(profileId);

    return interactionsResult.fold((failure) => Left(failure), (
      interactions,
    ) async {
      final excludedMovieIds = interactions.map((i) => i.movieId).toSet();

      // Fetch candidates from TMDB
      // Strategy: We need enough candidates to pick 10 unique ones.
      // We'll try to fetch from a random page.
      // Rule 8 says: Generate seed based on date.
      // We'll use the date to pick a "starting" page.
      int pageToCheck = (date.day * date.month * date.year) % 50 + 1;

      // Note: To truly guarantee 10 items after filtering watched/ignored,
      // we might need to fetch multiple pages if the user has watched A LOT.
      // For simplicity/performance now, we'll fetch one page (20 items).
      // If that's not enough, we could fetch another.
      // Let's implement a simple retry or just fetch 2 pages initially?
      // Let's stick to 1 page for now, usually sufficient unless user watched 10+ movies from that specific random page.

      final tmdbResult = await repository.discoverMovies(page: pageToCheck);

      return tmdbResult.fold((failure) => Left(failure), (movies) async {
        // Filter
        final candidates = movies
            .where((m) => !excludedMovieIds.contains(m.id))
            .toList();

        // If we don't have 10, we really should fetch more.
        // But strict requirement says "select 10".
        // If < 10 available on this page, take all and maybe warn or leave it.
        // Requirement: "si hoy hay 3 u 8 guardadas, debe reemplazarlas por 10."
        // If we physically can't find 10 (e.g. extremely rare case or errors), we return what we have?
        // Let's try to be robust. If candidates < 10, try next page.

        if (candidates.length < 10) {
          final extraPageResult = await repository.discoverMovies(
            page: pageToCheck + 1,
          );
          if (extraPageResult.isRight()) {
            final extraMovies = extraPageResult.getOrElse(() => []);
            final extraCandidates = extraMovies.where(
              (m) => !excludedMovieIds.contains(m.id),
            );
            candidates.addAll(extraCandidates);
          }
        }

        if (candidates.isEmpty) {
          return const Left(ServerFailure('No movies found to select'));
        }

        candidates.shuffle();

        // Take 10
        final selected = candidates.take(10).toList();

        final newSelection = DailySelection(
          profileId: profileId,
          date: date,
          movies: selected,
        );

        // Save (Upsert logic should be handled by repo)
        await repository.saveDailySelection(newSelection);

        return Right(newSelection);
      });
    });
  }
}

class MarkMovieWatched {
  final MovieRepository repository;
  MarkMovieWatched(this.repository);

  Future<Either<Failure, void>> call(String profileId, int movieId) {
    return repository.saveInteraction(
      Interaction(
        profileId: profileId,
        movieId: movieId,
        status: InteractionStatus.watched,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class MarkMovieIgnored {
  final MovieRepository repository;
  MarkMovieIgnored(this.repository);

  Future<Either<Failure, void>> call(String profileId, int movieId) {
    return repository.saveInteraction(
      Interaction(
        profileId: profileId,
        movieId: movieId,
        status: InteractionStatus.ignored,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
