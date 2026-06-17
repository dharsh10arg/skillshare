<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory;
    use Notifiable;

    protected $fillable = [
        'role_id', 'name', 'username', 'email', 'password', 'avatar_path', 'bio',
        'skills_offered', 'skills_wanted', 'skill_score', 'reliability_score',
        'community_score', 'reputation_score', 'completed_sessions', 'completed_projects',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected $casts = [
        'skills_offered' => 'array',
        'skills_wanted' => 'array',
        'email_verified_at' => 'datetime',
        'banned_at' => 'datetime',
    ];

    public function role() { return $this->belongsTo(Role::class); }
    public function wallet() { return $this->hasOne(Wallet::class); }
    public function listings() { return $this->hasMany(SkillListing::class); }
    public function achievements() { return $this->belongsToMany(Achievement::class)->withTimestamps(); }
}

