class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.postType,
    required this.createdAt,
    this.userName,
    this.userUsername,
    this.answerCount = 0,
  });

  final int id;
  final int userId;
  final String title;
  final String content;
  final String postType; // 'question', 'tutorial', 'help'
  final DateTime createdAt;
  final String? userName;
  final String? userUsername;
  final int answerCount;

  factory CommunityPost.fromJson(
    Map<String, dynamic> json, {
    String defaultPostType = 'question',
  }) {
    final createdAt = json['created_at'] as String? ?? json['createdAt'] as String? ?? '';
    return CommunityPost(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      postType: json['post_type'] as String? ?? json['type'] as String? ?? defaultPostType,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      userName: json['user']?['name'] as String?,
      userUsername: json['user']?['username'] as String?,
      answerCount: json['answer_count'] as int? ?? json['answers_count'] as int? ?? 0,
    );
  }
}
