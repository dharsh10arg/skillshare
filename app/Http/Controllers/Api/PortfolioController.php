<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Contribution;
use App\Models\Review;
use App\Models\User;

class PortfolioController extends Controller
{
    public function show(string $username)
    {
        $user = User::with(['achievements', 'wallet'])->where('username', $username)->firstOrFail();
        return [
            'profile' => $user,
            'projects' => Contribution::where('user_id', $user->id)->latest()->get(),
            'sessions' => Review::where('reviewee_id', $user->id)->latest()->get(),
            'certificates' => $user->achievements,
        ];
    }
}

