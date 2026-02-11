import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_result.dart';
import 'details_provider.dart';

class SearchState {
  final List<SearchResult> results;
  final bool isLoading;
  final String? errorMessage;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    List<SearchResult>? results,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return const SearchState();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final searchMulti = ref.read(searchMultiProvider);
    final result = await searchMulti(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (results) => state = state.copyWith(isLoading: false, results: results),
    );
  }

  void clear() {
    state = const SearchState();
  }
}

final globalSearchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
