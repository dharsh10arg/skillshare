class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.bookingId,
  });

  final int id;
  final int senderId;
  final int recipientId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final int? bookingId;

  factory Message.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] as String? ?? json['createdAt'] as String? ?? '';
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int? ?? json['senderId'] as int? ?? 0,
      recipientId: json['recipient_id'] as int? ?? json['recipientId'] as int? ?? 0,
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      senderName: json['sender']?['name'] as String?,
      bookingId: json['booking_id'] as int? ?? json['bookingId'] as int?,
    );
  }
}
