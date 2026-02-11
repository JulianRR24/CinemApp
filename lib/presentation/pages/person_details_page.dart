import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/movie.dart'; // We need to map MovieCredit to Movie if using MoviePosterCard
import '../providers/details_provider.dart';
import '../widgets/movie_poster_card.dart';

class PersonDetailsPage extends ConsumerWidget {
  final int personId;

  const PersonDetailsPage({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personDetailsAsync = ref.watch(personDetailsProvider(personId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: personDetailsAsync.when(
        data: (person) => _buildContent(context, person),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Person person) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          const SizedBox(height: 80), // For AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo
                Container(
                  width: 150,
                  height: 225,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: person.profilePath != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w500${person.profilePath}',
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white54,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (person.birthday != null)
                        Text(
                          'Nacimiento: ${person.birthday}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      if (person.placeOfBirth != null)
                        Text(
                          'Lugar: ${person.placeOfBirth}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Biografía',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        person.biography != null && person.biography!.isNotEmpty
                            ? person.biography!
                            : 'No hay biografía disponible en español.',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Filmography Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filmografía',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (person.movieCredits != null)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: person.movieCredits!.length,
                    itemBuilder: (context, index) {
                      final credit = person.movieCredits![index];

                      // Need to convert MovieCredit to Movie object for the card, or make a simpler card.
                      // MoviePosterCard expects Movie entity.
                      // Let's create a Movie object from credit.
                      final movie = Movie(
                        id: credit.id,
                        title: credit.title,
                        overview: '', // Not needed for card usually
                        posterPath: credit.posterPath,
                        releaseDate: credit.releaseDate ?? '',
                        voteAverage: credit.voteAverage ?? 0.0,
                        // Ensure other fields are non-null
                      );

                      return Stack(
                        children: [
                          MoviePosterCard(
                            movie: movie,
                            onTap: () => context.push(
                              '/movie/${credit.id}',
                              extra: movie,
                            ),
                          ),
                          // Character Name Overlay
                          if (credit.character != null &&
                              credit.character!.isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.7),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  credit.character!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                else
                  const Text(
                    'No hay filmografía disponible.',
                    style: TextStyle(color: Colors.white54),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
