import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import 'movie_poster_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie) onTap;
  final Function(Movie)? onWatched;
  final Function(Movie)? onIgnored;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.onTap,
    this.onWatched,
    this.onIgnored,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount = 2; // Default Mobile

        if (width >= 1200) {
          crossAxisCount = 5; // Desktop Large
        } else if (width >= 900) {
          crossAxisCount = 4; // Desktop/Tablet Landscape
        } else if (width >= 600) {
          crossAxisCount = 3; // Tablet Portrait
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio:
                2 / 3.4, // Width / Height (Poster aspect + Text space)
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return MoviePosterItem(
              movie: movie,
              onTap: () => onTap(movie),
              onWatched: onWatched != null ? () => onWatched!(movie) : null,
              onIgnored: onIgnored != null ? () => onIgnored!(movie) : null,
            );
          },
        );
      },
    );
  }
}
