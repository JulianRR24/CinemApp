import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/movie.dart';
import 'providers.dart';

class FilterParams {
  final String sortBy;
  final List<String> withGenres;
  final DateTime? releaseDateGte;
  final DateTime? releaseDateLte;
  final double? voteAverageGte;
  final String? withOriginalLanguage;

  const FilterParams({
    this.sortBy = 'popularity.desc',
    this.withGenres = const [],
    this.releaseDateGte,
    this.releaseDateLte,
    this.voteAverageGte,
    this.withOriginalLanguage,
  });

  FilterParams copyWith({
    String? sortBy,
    List<String>? withGenres,
    DateTime? releaseDateGte,
    DateTime? releaseDateLte,
    double? voteAverageGte,
    String? withOriginalLanguage,
  }) {
    return FilterParams(
      sortBy: sortBy ?? this.sortBy,
      withGenres: withGenres ?? this.withGenres,
      releaseDateGte: releaseDateGte ?? this.releaseDateGte,
      releaseDateLte: releaseDateLte ?? this.releaseDateLte,
      voteAverageGte: voteAverageGte ?? this.voteAverageGte,
      withOriginalLanguage: withOriginalLanguage ?? this.withOriginalLanguage,
    );
  }
}

class CatalogState {
  final List<Movie> movies;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? errorMessage;
  final FilterParams filters;

  const CatalogState({
    required this.movies,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.errorMessage,
    this.filters = const FilterParams(),
  });

  CatalogState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? errorMessage,
    FilterParams? filters,
  }) {
    return CatalogState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: errorMessage,
      filters: filters ?? this.filters,
    );
  }
}

class CatalogNotifier extends Notifier<CatalogState> {
  @override
  CatalogState build() {
    // Initial load
    Future.microtask(() => fetchNextPage());
    return const CatalogState(movies: [], isLoading: true);
  }

  Future<void> fetchNextPage() async {
    if (!state.hasMore) return;

    if (state.isLoading && state.movies.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await ref
        .read(movieRepositoryProvider)
        .discoverMovies(
          page: state.page,
          sortBy: state.filters.sortBy,
          withGenres: state.filters.withGenres.isNotEmpty
              ? state.filters.withGenres.join(',')
              : null,
          releaseDateGte: state.filters.releaseDateGte?.toIso8601String().split(
            'T',
          )[0],
          releaseDateLte: state.filters.releaseDateLte?.toIso8601String().split(
            'T',
          )[0],
          voteAverageGte: state.filters.voteAverageGte,
          withOriginalLanguage: state.filters.withOriginalLanguage,
        );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (newMovies) {
        if (newMovies.isEmpty) {
          state = state.copyWith(isLoading: false, hasMore: false);
        } else {
          state = state.copyWith(
            isLoading: false,
            hasMore: true,
            movies: [...state.movies, ...newMovies],
            page: state.page + 1,
          );
        }
      },
    );
  }

  void updateFilters(FilterParams newFilters) {
    state = state.copyWith(
      filters: newFilters,
      movies: [], // Clear list
      page: 1, // Reset page
      hasMore: true,
      isLoading: true,
    );
    fetchNextPage();
  }

  void resetFilters() {
    updateFilters(const FilterParams());
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(() {
  return CatalogNotifier();
});
