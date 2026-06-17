<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('roles', fn (Blueprint $t) => [$t->id(), $t->string('name')->unique()]);
        Schema::create('users', function (Blueprint $t) {
            $t->id(); $t->foreignId('role_id')->constrained(); $t->string('name'); $t->string('username')->unique(); $t->string('email')->unique(); $t->string('password'); $t->string('avatar_path')->nullable(); $t->text('bio')->nullable(); $t->json('skills_offered')->nullable(); $t->json('skills_wanted')->nullable(); $t->unsignedTinyInteger('skill_score')->default(50); $t->unsignedTinyInteger('reliability_score')->default(50); $t->unsignedTinyInteger('community_score')->default(50); $t->unsignedTinyInteger('reputation_score')->default(50); $t->unsignedInteger('completed_sessions')->default(0); $t->unsignedInteger('completed_projects')->default(0); $t->timestamp('email_verified_at')->nullable(); $t->timestamp('banned_at')->nullable(); $t->rememberToken(); $t->timestamps();
        });
        Schema::create('wallets', fn (Blueprint $t) => [$t->id(), $t->foreignId('user_id')->nullable()->constrained()->cascadeOnDelete(), $t->enum('type', ['user', 'treasury'])->index(), $t->integer('balance')->default(0), $t->timestamps()]);
        Schema::create('transactions', fn (Blueprint $t) => [$t->id(), $t->foreignId('from_wallet_id')->nullable()->references('id')->on('wallets'), $t->foreignId('to_wallet_id')->nullable()->references('id')->on('wallets'), $t->integer('amount'), $t->string('type')->index(), $t->string('description'), $t->json('metadata')->nullable(), $t->timestamps()]);
        Schema::create('skills', fn (Blueprint $t) => [$t->id(), $t->string('name')->unique(), $t->string('category')->index(), $t->timestamps()]);
        Schema::create('skill_listings', fn (Blueprint $t) => [$t->id(), $t->foreignId('user_id')->constrained()->cascadeOnDelete(), $t->foreignId('skill_id')->constrained(), $t->string('title'), $t->text('description')->nullable(), $t->unsignedSmallInteger('duration_minutes'), $t->enum('expertise_level', ['beginner', 'intermediate', 'advanced', 'expert']), $t->json('availability')->nullable(), $t->boolean('is_active')->default(true), $t->timestamps()]);
        Schema::create('bookings', fn (Blueprint $t) => [$t->id(), $t->foreignId('student_id')->references('id')->on('users'), $t->foreignId('teacher_id')->references('id')->on('users'), $t->foreignId('skill_listing_id')->constrained(), $t->unsignedSmallInteger('duration_minutes'), $t->enum('status', ['requested', 'accepted', 'scheduled', 'completed', 'cancelled'])->index(), $t->timestamp('scheduled_at')->nullable(), $t->text('notes')->nullable(), $t->timestamps()]);
        Schema::create('sessions', fn (Blueprint $t) => [$t->id(), $t->foreignId('booking_id')->constrained(), $t->timestamp('started_at')->nullable(), $t->timestamp('ended_at')->nullable(), $t->unsignedInteger('timer_seconds')->default(0), $t->string('status')->default('pending'), $t->timestamps()]);
        Schema::create('reviews', fn (Blueprint $t) => [$t->id(), $t->foreignId('reviewer_id')->references('id')->on('users'), $t->foreignId('reviewee_id')->references('id')->on('users'), $t->foreignId('booking_id')->constrained(), $t->unsignedTinyInteger('rating'), $t->text('body')->nullable(), $t->timestamps()]);
        Schema::create('projects', fn (Blueprint $t) => [$t->id(), $t->foreignId('owner_id')->references('id')->on('users'), $t->string('title'), $t->text('description'), $t->json('roles_required'), $t->string('duration')->nullable(), $t->json('skills_required'), $t->string('status')->default('open'), $t->timestamps()]);
        Schema::create('project_members', fn (Blueprint $t) => [$t->id(), $t->foreignId('project_id')->constrained()->cascadeOnDelete(), $t->foreignId('user_id')->constrained()->cascadeOnDelete(), $t->string('role'), $t->string('status')->default('applied'), $t->timestamps(), $t->unique(['project_id', 'user_id'])]);
        Schema::create('contributions', fn (Blueprint $t) => [$t->id(), $t->foreignId('project_id')->constrained()->cascadeOnDelete(), $t->foreignId('user_id')->constrained()->cascadeOnDelete(), $t->enum('type', ['frontend', 'backend', 'testing', 'documentation', 'design']), $t->text('description'), $t->unsignedInteger('credits_awarded')->default(0), $t->timestamps()]);
        Schema::create('questions', fn (Blueprint $t) => [$t->id(), $t->foreignId('user_id')->constrained(), $t->string('title'), $t->text('body'), $t->json('tags')->nullable(), $t->timestamps()]);
        Schema::create('answers', fn (Blueprint $t) => [$t->id(), $t->foreignId('question_id')->constrained()->cascadeOnDelete(), $t->foreignId('user_id')->constrained(), $t->text('body'), $t->boolean('is_accepted')->default(false), $t->unsignedInteger('helpful_count')->default(0), $t->timestamps()]);
        Schema::create('tutorials', fn (Blueprint $t) => [$t->id(), $t->foreignId('user_id')->constrained(), $t->string('title'), $t->longText('body'), $t->json('tags')->nullable(), $t->string('status')->default('draft'), $t->timestamps()]);
        Schema::create('messages', fn (Blueprint $t) => [$t->id(), $t->uuid('thread_id')->index(), $t->foreignId('sender_id')->references('id')->on('users'), $t->foreignId('recipient_id')->references('id')->on('users'), $t->text('body'), $t->timestamp('read_at')->nullable(), $t->timestamps()]);
        Schema::create('notifications', fn (Blueprint $t) => [$t->id(), $t->foreignId('user_id')->constrained()->cascadeOnDelete(), $t->string('type'), $t->string('title'), $t->text('body')->nullable(), $t->json('data')->nullable(), $t->timestamp('read_at')->nullable(), $t->timestamps()]);
        Schema::create('achievements', fn (Blueprint $t) => [$t->id(), $t->string('name'), $t->text('description'), $t->unsignedInteger('credit_reward')->default(0), $t->string('badge')->nullable(), $t->timestamps()]);
        Schema::create('achievement_user', fn (Blueprint $t) => [$t->id(), $t->foreignId('achievement_id')->constrained()->cascadeOnDelete(), $t->foreignId('user_id')->constrained()->cascadeOnDelete(), $t->timestamps(), $t->unique(['achievement_id', 'user_id'])]);
        Schema::create('reports', fn (Blueprint $t) => [$t->id(), $t->foreignId('reporter_id')->references('id')->on('users'), $t->string('target_type'), $t->unsignedBigInteger('target_id'), $t->text('reason'), $t->string('status')->default('open'), $t->foreignId('resolved_by')->nullable()->references('id')->on('users'), $t->timestamps()]);
    }

    public function down(): void
    {
        foreach (array_reverse(['roles','users','wallets','transactions','skills','skill_listings','bookings','sessions','reviews','projects','project_members','contributions','questions','answers','tutorials','messages','notifications','achievements','achievement_user','reports']) as $table) {
            Schema::dropIfExists($table);
        }
    }
};

