import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/catalog_provider.dart';
import '../providers/providers.dart';
import '../widgets/movie_grid.dart';
import '../widgets/filter_panel.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(catalogProvider);
    final notifier = ref.read(catalogProvider.notifier);

    // Determine screen width for responsive layout
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          if (!isDesktop)
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
        ],
      ),
      endDrawer: !isDesktop
          ? Drawer(
              width: 300,
              child: FilterPanel(
                currentFilters: catalogState.filters,
                onApply: (params) {
                  notifier.updateFilters(params);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar Filters on Desktop
          if (isDesktop)
            FilterPanel(
              currentFilters: catalogState.filters,
              onApply: (params) => notifier.updateFilters(params),
            ),

          if (isDesktop) const VerticalDivider(width: 1),

          // Main Content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent * 0.8) {
                  notifier.fetchNextPage();
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async => notifier.resetFilters(),
                child: catalogState.movies.isEmpty && catalogState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : catalogState.movies.isEmpty && !catalogState.isLoading
                    ? const Center(child: Text('No movies found'))
                    : Column(
                        children: [
                          Expanded(
                            child: MovieGrid(
                              movies: catalogState.movies,
                              onTap: (movie) =>
                                  context.push('/details', extra: movie),
                              onWatched: (movie) async {
                                await ref
                                    .read(markMovieWatchedUseCaseProvider)
                                    .call('default_user_v1', movie.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Marked "${movie.title}" as Watched',
                                      ),
                                    ),
                                  );
                                }
                              },
                              onIgnored: (movie) async {
                                await ref
                                    .read(markMovieIgnoredUseCaseProvider)
                                    .call('default_user_v1', movie.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Marked "${movie.title}" as Ignored',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          if (catalogState.isLoading &&
                              catalogState.movies.isNotEmpty)
                            const LinearProgressIndicator(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
