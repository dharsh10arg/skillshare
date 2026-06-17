<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $roles)
    {
        $allowed = explode(',', $roles);
        abort_unless(in_array(auth()->user()?->role?->name, $allowed, true), 403);
        return $next($request);
    }
}

