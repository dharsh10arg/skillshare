class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.sessionsCompleted,
    required this.creditsCirculated,
    this.popularSkills = const [],
  });

  final int totalUsers;
  final int activeUsers;
  final int sessionsCompleted;
  final int creditsCirculated;
  final List<SkillStat> popularSkills;

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final popularSkillsList =
        (json['popular_skills'] as List<dynamic>?)?.map((item) {
          return SkillStat(
            title: item['title'] as String? ?? '',
            count: item['count'] as int? ?? 0,
          );
        }).toList() ??
        [];
    return AdminStats(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      sessionsCompleted: json['sessions_completed'] as int? ?? 0,
      creditsCirculated: json['credits_circulated'] as int? ?? 0,
      popularSkills: popularSkillsList,
    );
  }
}

class SkillStat {
  const SkillStat({required this.title, required this.count});
  final String title;
  final int count;
}
