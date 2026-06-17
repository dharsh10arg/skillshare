<?php

namespace App\Services;

use App\Models\User;

class ReputationService
{
    public function recalculate(User $user): int
    {
        $score = round(
            ($user->skill_score * 0.40) +
            ($user->reliability_score * 0.30) +
            ($user->community_score * 0.30)
        );

        $user->forceFill(['reputation_score' => max(0, min(100, $score))])->save();
        return $user->reputation_score;
    }
}

