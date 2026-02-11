import '../../domain/entities/credit.dart';

class CastModel extends Cast {
  const CastModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.character,
    super.order,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      character: json['character'],
      order: json['order'],
    );
  }
}

class CrewModel extends Crew {
  const CrewModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.job,
    super.department,
  });

  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
      job: json['job'],
      department: json['department'] ?? json['known_for_department'],
    );
  }
}
