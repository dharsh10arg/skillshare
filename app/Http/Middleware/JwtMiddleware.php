<?php

namespace App\Http\Middleware;

use App\Models\User;
use App\Services\JwtService;
use Closure;
use Illuminate\Http\Request;

class JwtMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $token = str_replace('Bearer ', '', (string) $request->header('Authorization'));
        try {
            $claims = app(JwtService::class)->parse($token);
            $user = User::query()->with('role', 'wallet')->findOrFail($claims['sub']);
            abort_if($user->banned_at, 403, 'User is banned.');
            auth()->setUser($user);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        return $next($request);
    }
}

