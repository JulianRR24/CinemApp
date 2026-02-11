import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? character;
  final int? order;

  const Cast({
    required this.id,
    required this.name,
    this.profilePath,
    this.character,
    this.order,
  });

  @override
  List<Object?> get props => [id, name, profilePath, character, order];
}

class Crew extends Equatable {
  final int id;
  final String name;
  final String? profilePath;
  final String? job;
  final String? department;

  const Crew({
    required this.id,
    required this.name,
    this.profilePath,
    this.job,
    this.department,
  });

  @override
  List<Object?> get props => [id, name, profilePath, job, department];
}
