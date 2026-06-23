class SkillListing {
  const SkillListing({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.expertiseLevel,
    required this.isActive,
    this.userName,
    this.userUsername,
  });

  final int id;
  final int userId;
  final String title;
  final String description;
  final int durationMinutes;
  final String expertiseLevel;
  final bool isActive;
  final String? userName;
  final String? userUsername;

  factory SkillListing.fromJson(Map<String, dynamic> json) {
    return SkillListing(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      expertiseLevel: json['expertise_level'] as String? ?? 'intermediate',
      isActive: json['is_active'] as bool? ?? true,
      userName: json['user']?['name'] as String?,
      userUsername: json['user']?['username'] as String?,
    );
  }
}
