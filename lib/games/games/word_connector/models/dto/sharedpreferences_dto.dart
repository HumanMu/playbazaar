class SharedpreferencesDto {
  int level;
  int count;
  int points;
  String language;

  SharedpreferencesDto({
    required this.level,
    required this.count,
    required this.language,
    required this.points
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'count': count,
      'language': language,
      'points': points
    };
  }

  SharedpreferencesDto copyWith({
    int? level,
    int? count,
    int? points,
    String? language,
  }) {
    return SharedpreferencesDto(
      level: level ?? this.level,
      count: count ?? this.count,
      points: points ?? this.points,
      language: language ?? this.language,
    );
  }

  factory SharedpreferencesDto.fromJson(Map<String, dynamic> json) {
    return SharedpreferencesDto(
      level: json['level'],
      count: json['count'],
      language: json['language'],
      points: json['points']
    );
  }
}
