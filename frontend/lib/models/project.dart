class Project {
  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.skillsNeeded = const [],
    this.rewardCredits = 0,
  });

  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final List<String> skillsNeeded;
  final int rewardCredits;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
      skillsNeeded: (json['skills_needed'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rewardCredits: json['reward_credits'] as int? ?? 0,
    );
  }
}
