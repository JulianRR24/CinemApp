import 'package:equatable/equatable.dart';
import 'movie.dart';
import 'person.dart';

abstract class SearchResult extends Equatable {
  const SearchResult();

  @override
  List<Object?> get props => [];
}

class MovieSearchResult extends SearchResult {
  final Movie movie;
  const MovieSearchResult(this.movie);

  @override
  List<Object?> get props => [movie];
}

class PersonSearchResult extends SearchResult {
  final Person person;
  const PersonSearchResult(this.person);

  @override
  List<Object?> get props => [person];
}
