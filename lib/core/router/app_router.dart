import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/history_page.dart';
import '../../presentation/pages/details_page.dart';
import '../../presentation/pages/person_details_page.dart';
import '../../presentation/widgets/scaffold_with_nav.dart';
import '../../domain/entities/movie.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
      ],
    ),
    // Details Routes (outside Shell to cover bottom bar?)
    // User often wants details to cover everything. `parentNavigatorKey: _rootNavigatorKey`.
    GoRoute(
      path: '/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        final movie = state.extra as Movie?;
        return MovieDetailsPage(movieId: id, placeholderMovie: movie);
      },
    ),
    GoRoute(
      path: '/person/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '') ?? 0;
        return PersonDetailsPage(personId: id);
      },
    ),
  ],
);
