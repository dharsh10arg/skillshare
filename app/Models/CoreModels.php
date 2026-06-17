<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Role extends Model { protected $fillable = ['name']; public $timestamps = false; }
class Wallet extends Model { protected $fillable = ['user_id', 'type', 'balance']; public function user() { return $this->belongsTo(User::class); } }
class Transaction extends Model { protected $fillable = ['from_wallet_id', 'to_wallet_id', 'amount', 'type', 'description', 'metadata']; protected $casts = ['metadata' => 'array']; }
class Skill extends Model { protected $fillable = ['name', 'category']; }
class SkillListing extends Model { protected $fillable = ['user_id', 'skill_id', 'title', 'description', 'duration_minutes', 'expertise_level', 'availability', 'is_active']; protected $casts = ['availability' => 'array', 'is_active' => 'boolean']; public function user() { return $this->belongsTo(User::class); } public function skill() { return $this->belongsTo(Skill::class); } }
class Booking extends Model { protected $fillable = ['student_id', 'teacher_id', 'skill_listing_id', 'duration_minutes', 'status', 'scheduled_at', 'notes']; protected $casts = ['scheduled_at' => 'datetime']; public function student() { return $this->belongsTo(User::class, 'student_id'); } public function teacher() { return $this->belongsTo(User::class, 'teacher_id'); } }
class Session extends Model { protected $fillable = ['booking_id', 'started_at', 'ended_at', 'timer_seconds', 'status']; protected $casts = ['started_at' => 'datetime', 'ended_at' => 'datetime']; }
class Review extends Model { protected $fillable = ['reviewer_id', 'reviewee_id', 'booking_id', 'rating', 'body']; }
class Project extends Model { protected $fillable = ['owner_id', 'title', 'description', 'roles_required', 'duration', 'skills_required', 'status']; protected $casts = ['roles_required' => 'array', 'skills_required' => 'array']; }
class ProjectMember extends Model { protected $fillable = ['project_id', 'user_id', 'role', 'status']; }
class Contribution extends Model { protected $fillable = ['project_id', 'user_id', 'type', 'description', 'credits_awarded']; }
class Question extends Model { protected $fillable = ['user_id', 'title', 'body', 'tags']; protected $casts = ['tags' => 'array']; }
class Answer extends Model { protected $fillable = ['question_id', 'user_id', 'body', 'is_accepted', 'helpful_count']; protected $casts = ['is_accepted' => 'boolean']; }
class Tutorial extends Model { protected $fillable = ['user_id', 'title', 'body', 'tags', 'status']; protected $casts = ['tags' => 'array']; }
class Message extends Model { protected $fillable = ['thread_id', 'sender_id', 'recipient_id', 'body', 'read_at']; protected $casts = ['read_at' => 'datetime']; }
class Notification extends Model { protected $fillable = ['user_id', 'type', 'title', 'body', 'data', 'read_at']; protected $casts = ['data' => 'array', 'read_at' => 'datetime']; }
class Achievement extends Model { protected $fillable = ['name', 'description', 'credit_reward', 'badge']; }
class Report extends Model { protected $fillable = ['reporter_id', 'target_type', 'target_id', 'reason', 'status', 'resolved_by']; }
