import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/person.dart';
import '../../domain/usecases/movie_usecases.dart';
import 'providers.dart';

// UseCases Providers
final getMovieDetailsProvider = Provider<GetMovieDetails>((ref) {
  return GetMovieDetails(ref.read(movieRepositoryProvider));
});

final getPersonDetailsProvider = Provider<GetPersonDetails>((ref) {
  return GetPersonDetails(ref.read(movieRepositoryProvider));
});

final searchMultiProvider = Provider<SearchMulti>((ref) {
  return SearchMulti(ref.read(movieRepositoryProvider));
});

// State Providers for UI
final movieDetailsProvider = FutureProvider.family<MovieDetail, int>((
  ref,
  movieId,
) async {
  final getMovieDetails = ref.read(getMovieDetailsProvider);
  final result = await getMovieDetails(movieId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (movie) => movie,
  );
});

final personDetailsProvider = FutureProvider.family<Person, int>((
  ref,
  personId,
) async {
  final getPersonDetails = ref.read(getPersonDetailsProvider);
  final result = await getPersonDetails(personId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (person) => person,
  );
});
