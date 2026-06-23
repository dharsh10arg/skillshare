class Booking {
  const Booking({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.skillListingId,
    required this.status,
    required this.durationMinutes,
    this.scheduledAt,
    this.notes,
    this.teacherName,
    this.skillTitle,
  });

  final int id;
  final int studentId;
  final int teacherId;
  final int skillListingId;
  final String status;
  final int durationMinutes;
  final DateTime? scheduledAt;
  final String? notes;
  final String? teacherName;
  final String? skillTitle;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      teacherId: json['teacher_id'] as int,
      skillListingId: json['skill_listing_id'] as int,
      status: json['status'] as String? ?? 'requested',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      notes: json['notes'] as String?,
      teacherName: json['teacher']?['name'] as String?,
      skillTitle: json['skill_listing']?['title'] as String?,
    );
  }
}
