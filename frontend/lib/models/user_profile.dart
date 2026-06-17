class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    required this.walletBalance,
    required this.reputationScore,
    required this.reliabilityScore,
    required this.communityScore,
    required this.completedSessions,
    required this.completedProjects,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  final int walletBalance;
  final int reputationScore;
  final int reliabilityScore;
  final int communityScore;
  final int completedSessions;
  final int completedProjects;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role:
          (json['role'] as Map<String, dynamic>?)?['name'] as String? ?? 'user',
      walletBalance:
          (json['wallet'] as Map<String, dynamic>?)?['balance'] as int? ?? 0,
      reputationScore: json['reputation_score'] as int? ?? 50,
      reliabilityScore: json['reliability_score'] as int? ?? 50,
      communityScore: json['community_score'] as int? ?? 50,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
    );
  }
}
