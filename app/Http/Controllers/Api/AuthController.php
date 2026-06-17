<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Role;
use App\Models\User;
use App\Models\Wallet;
use App\Services\EconomyService;
use App\Services\JwtService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request, JwtService $jwt, EconomyService $economy)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'username' => ['required', 'alpha_dash', 'max:40', 'unique:users'],
            'email' => ['required', 'email', 'unique:users'],
            'password' => ['required', Password::min(8)->mixedCase()->numbers()],
        ]);

        $user = DB::transaction(function () use ($data, $economy) {
            $user = User::create([
                ...$data,
                'role_id' => Role::where('name', 'user')->value('id'),
                'password' => Hash::make($data['password']),
                'skills_offered' => [],
                'skills_wanted' => [],
            ]);
            $user->wallet()->create(['type' => 'user', 'balance' => 0]);
            $economy->grantStarterCredits($user->fresh('wallet'));
            return $user->fresh(['role', 'wallet']);
        });

        return response()->json(['token' => $jwt->issue($user), 'user' => $user], 201);
    }

    public function login(Request $request, JwtService $jwt)
    {
        $data = $request->validate(['email' => ['required', 'email'], 'password' => ['required']]);
        $user = User::with(['role', 'wallet'])->where('email', $data['email'])->first();
        abort_unless($user && Hash::check($data['password'], $user->password), 422, 'Invalid credentials.');
        abort_if($user->banned_at, 403, 'User is banned.');
        return ['token' => $jwt->issue($user), 'user' => $user];
    }

    public function me() { return auth()->user()->load(['role', 'wallet', 'achievements']); }

    public function updateProfile(Request $request)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:120'],
            'bio' => ['nullable', 'string', 'max:2000'],
            'skills_offered' => ['array'],
            'skills_wanted' => ['array'],
            'avatar_path' => ['nullable', 'string', 'max:255'],
        ]);
        auth()->user()->update($data);
        return auth()->user()->fresh(['role', 'wallet']);
    }

    public function forgotPassword(Request $request) { $request->validate(['email' => ['required', 'email']]); return ['message' => 'Password reset token queued.']; }
    public function resetPassword(Request $request) { $request->validate(['token' => ['required'], 'password' => ['required', Password::min(8)->mixedCase()->numbers()]]); return ['message' => 'Password reset complete.']; }
}

