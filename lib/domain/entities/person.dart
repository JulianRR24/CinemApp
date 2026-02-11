import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? knownForDepartment;

  // Detail fields (nullable)
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final double? popularity;
  final List<MovieCredit>? movieCredits;

  const Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.knownForDepartment,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.popularity,
    this.movieCredits,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    profilePath,
    knownForDepartment,
    biography,
    birthday,
    deathday,
    placeOfBirth,
    popularity,
    movieCredits,
  ];
}

class MovieCredit extends Equatable {
  final int id;
  final String title;
  final String? posterPath;
  final String? character;
  final String? releaseDate;
  final double? voteAverage;

  const MovieCredit({
    required this.id,
    required this.title,
    this.posterPath,
    this.character,
    this.releaseDate,
    this.voteAverage,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    posterPath,
    character,
    releaseDate,
    voteAverage,
  ];
}
