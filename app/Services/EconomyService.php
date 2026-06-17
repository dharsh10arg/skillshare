<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class EconomyService
{
    public const STARTER_CREDITS = 10;
    public const TEACHING_REWARDS = [30 => 5, 60 => 10, 120 => 20];
    public const LEARNING_COSTS = [30 => 4, 60 => 8, 120 => 16];
    public const COMMUNITY_REWARDS = ['helpful_answer' => 1, 'accepted_answer' => 3, 'tutorial_upload' => 5];

    public function grantStarterCredits(User $user): void
    {
        $this->mintFromTreasury($user->wallet, self::STARTER_CREDITS, 'starter_bonus', 'New user starter credits');
    }

    public function completeTeachingSession(User $teacher, User $student, int $duration): void
    {
        $reward = self::TEACHING_REWARDS[$duration] ?? throw new InvalidArgumentException('Unsupported duration.');
        $cost = self::LEARNING_COSTS[$duration] ?? throw new InvalidArgumentException('Unsupported duration.');

        DB::transaction(function () use ($teacher, $student, $reward, $cost, $duration) {
            $this->debit($student->wallet, $cost, 'learning_session', "Learned for {$duration} minutes");
            $this->credit($teacher->wallet, $reward, 'teaching_session', "Taught for {$duration} minutes");
        });
    }

    public function rewardCommunity(User $user, string $activity): void
    {
        $amount = self::COMMUNITY_REWARDS[$activity] ?? throw new InvalidArgumentException('Unsupported reward.');
        $this->mintFromTreasury($user->wallet, $amount, $activity, 'Community contribution reward');
    }

    public function mintFromTreasury(Wallet $to, int $amount, string $type, string $description): void
    {
        DB::transaction(function () use ($to, $amount, $type, $description) {
            $treasury = Wallet::query()->where('type', 'treasury')->lockForUpdate()->firstOrFail();
            $this->credit($to, $amount, $type, $description, $treasury);
        });
    }

    private function credit(Wallet $wallet, int $amount, string $type, string $description, ?Wallet $from = null): void
    {
        $wallet->increment('balance', $amount);
        Transaction::create([
            'from_wallet_id' => $from?->id,
            'to_wallet_id' => $wallet->id,
            'amount' => $amount,
            'type' => $type,
            'description' => $description,
            'metadata' => [],
        ]);
    }

    private function debit(Wallet $wallet, int $amount, string $type, string $description): void
    {
        if ($wallet->balance < $amount) {
            throw new InvalidArgumentException('Insufficient credits.');
        }

        $wallet->decrement('balance', $amount);
        Transaction::create([
            'from_wallet_id' => $wallet->id,
            'amount' => $amount,
            'type' => $type,
            'description' => $description,
            'metadata' => [],
        ]);
    }
}

