import '../../domain/entities/person.dart';

// But MovieCredit needs a model too? Or we can map manually in PersonModel.

class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.knownForDepartment,
    super.biography,
    super.birthday,
    super.deathday,
    super.placeOfBirth,
    super.popularity,
    super.movieCredits,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    // Movie Credits
    final creditsData = json['movie_credits'];
    final castList = creditsData != null && creditsData['cast'] != null
        ? (creditsData['cast'] as List)
              .map((e) => MovieCreditModel.fromJson(e))
              .toList()
        : <MovieCredit>[];

    // Sort by release date desc
    castList.sort((a, b) {
      if (a.releaseDate == null || a.releaseDate!.isEmpty) return 1;
      if (b.releaseDate == null || b.releaseDate!.isEmpty) return -1;
      return b.releaseDate!.compareTo(a.releaseDate!);
    });

    return PersonModel(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      knownForDepartment: json['known_for_department'],
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      placeOfBirth: json['place_of_birth'],
      popularity: (json['popularity'] as num?)?.toDouble(),
      movieCredits: castList,
    );
  }
}

class MovieCreditModel extends MovieCredit {
  const MovieCreditModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.character,
    super.releaseDate,
    super.voteAverage,
  });

  factory MovieCreditModel.fromJson(Map<String, dynamic> json) {
    return MovieCreditModel(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'],
      character: json['character'],
      releaseDate: json['release_date'],
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
    );
  }
}
