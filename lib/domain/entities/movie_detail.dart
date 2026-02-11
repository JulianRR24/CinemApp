import 'package:equatable/equatable.dart';
import 'movie.dart';
import 'credit.dart';

class MovieDetail extends Movie {
  final String? tagline;
  final String? status;
  final List<Genre>? genresList;
  final List<Cast>? cast;
  final List<Crew>? crew;
  final List<String>? videoKeys; // Youtube keys
  final List<String>? images; // Backdrops/Posters
  final List<Movie>? recommendations;
  final List<Movie>? similar;

  const MovieDetail({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.releaseDate,
    required super.voteAverage,
    super.voteCount, // Need to add to Movie if not there?
    super.popularity, // Need to add to Movie?
    super.runtime,
    this.tagline,
    this.status,
    this.genresList,
    this.cast,
    this.crew,
    this.videoKeys,
    this.images,
    this.recommendations,
    this.similar,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    tagline,
    status,
    genresList,
    cast,
    crew,
    videoKeys,
    images,
    recommendations,
    similar,
  ];
}

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
