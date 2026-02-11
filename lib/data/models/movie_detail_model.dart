import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/movie.dart';
import 'credit_model.dart';
import 'movie_model.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.releaseDate,
    required super.voteAverage,
    super.voteCount,
    super.popularity,
    super.runtime,
    super.tagline,
    super.status,
    super.genresList,
    super.cast,
    super.crew,
    super.videoKeys,
    super.images,
    super.recommendations,
    super.similar,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    // Genres
    final genresList = json['genres'] != null
        ? (json['genres'] as List)
              .map((e) => Genre(id: e['id'], name: e['name']))
              .toList()
        : <Genre>[];

    // Credits
    final credits = json['credits'];
    final cast = credits != null && credits['cast'] != null
        ? (credits['cast'] as List).map((e) => CastModel.fromJson(e)).toList()
        : <CastModel>[];
    final crew = credits != null && credits['crew'] != null
        ? (credits['crew'] as List).map((e) => CrewModel.fromJson(e)).toList()
        : <CrewModel>[];

    // Videos (Youtube)
    final videos = json['videos'];
    final videoKeys = videos != null && videos['results'] != null
        ? (videos['results'] as List)
              .where(
                (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
              ) // Prioritize Trailer
              .map<String>((v) => v['key'] as String)
              .toList()
        : <String>[];

    // If no trailer found, maybe include Teasers or Clips?
    // Let's just grab all youtube keys but maybe sort? For now just Trailers.
    // User asked for "Trailer oficial".

    // Images (Backdrops/Posters)
    final imagesData = json['images'];
    final imagePaths = <String>[];
    if (imagesData != null) {
      if (imagesData['backdrops'] != null) {
        imagePaths.addAll(
          (imagesData['backdrops'] as List).map(
            (e) => e['file_path'] as String,
          ),
        );
      }
      if (imagesData['posters'] != null) {
        imagePaths.addAll(
          (imagesData['posters'] as List).map((e) => e['file_path'] as String),
        );
      }
    }

    // Recommendations & Similar
    final recsData = json['recommendations'];
    final recommendations = recsData != null && recsData['results'] != null
        ? (recsData['results'] as List)
              .map((e) => MovieModel.fromJson(e))
              .toList()
        : <Movie>[];

    final simData = json['similar'];
    final similar = simData != null && simData['results'] != null
        ? (simData['results'] as List)
              .map((e) => MovieModel.fromJson(e))
              .toList()
        : <Movie>[];

    return MovieDetailModel(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      runtime: json['runtime'],
      tagline: json['tagline'],
      status: json['status'],
      genresList: genresList,
      cast: cast,
      crew: crew,
      videoKeys: videoKeys,
      images: imagePaths,
      recommendations: recommendations,
      similar: similar,
    );
  }
}
