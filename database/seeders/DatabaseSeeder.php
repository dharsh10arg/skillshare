<?php

namespace Database\Seeders;

use App\Models\Achievement;
use App\Models\Role;
use App\Models\Skill;
use App\Models\SkillListing;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        foreach (['user', 'moderator', 'admin'] as $role) {
            Role::firstOrCreate(['name' => $role]);
        }

        Wallet::firstOrCreate(['type' => 'treasury', 'user_id' => null], ['balance' => 1000000]);

        $accounts = [
            ['Admin', 'admin', 'admin@skillsphere.local', 'admin'],
            ['Moderator', 'moderator', 'moderator@skillsphere.local', 'moderator'],
            ['Maya Chen', 'maya', 'maya@skillsphere.local', 'user'],
        ];

        foreach ($accounts as [$name, $username, $email, $role]) {
            $user = User::firstOrCreate(['email' => $email], [
                'name' => $name,
                'username' => $username,
                'role_id' => Role::where('name', $role)->value('id'),
                'password' => Hash::make('Password123!'),
                'bio' => 'Building skills through time credits.',
                'skills_offered' => ['Flutter', 'Laravel'],
                'skills_wanted' => ['Product design'],
            ]);
            Wallet::firstOrCreate(['user_id' => $user->id], ['type' => 'user', 'balance' => 10]);
        }

        foreach ([['Flutter', 'Engineering'], ['Laravel', 'Engineering'], ['Resume Review', 'Career'], ['UI Feedback', 'Design']] as [$name, $category]) {
            Skill::firstOrCreate(['name' => $name], ['category' => $category]);
        }

        SkillListing::firstOrCreate(['title' => 'Flutter app architecture'], [
            'user_id' => User::where('username', 'maya')->value('id'),
            'skill_id' => Skill::where('name', 'Flutter')->value('id'),
            'description' => 'Provider, clean API clients, and responsive Material 3 screens.',
            'duration_minutes' => 60,
            'expertise_level' => 'advanced',
            'availability' => ['weekdays' => ['18:00-21:00']],
            'is_active' => true,
        ]);

        Achievement::firstOrCreate(['name' => 'First Teacher'], ['description' => 'Complete the first teaching session.', 'credit_reward' => 3, 'badge' => 'mentor']);
    }
}

