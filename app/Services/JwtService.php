<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Str;
use RuntimeException;

class JwtService
{
    public function issue(User $user): string
    {
        $now = time();
        $payload = [
            'iss' => config('app.url'),
            'sub' => (string) $user->id,
            'role' => $user->role->name ?? 'user',
            'iat' => $now,
            'exp' => $now + config('jwt.ttl_minutes') * 60,
            'jti' => (string) Str::uuid(),
        ];

        return $this->encode(['alg' => 'HS256', 'typ' => 'JWT'], $payload);
    }

    public function parse(string $token): array
    {
        [$header, $payload, $signature] = explode('.', $token) + [null, null, null];
        if (!$header || !$payload || !$signature) {
            throw new RuntimeException('Malformed token.');
        }

        $expected = $this->sign($header . '.' . $payload);
        if (!hash_equals($expected, $signature)) {
            throw new RuntimeException('Invalid token signature.');
        }

        $claims = json_decode($this->b64decode($payload), true, 512, JSON_THROW_ON_ERROR);
        if (($claims['exp'] ?? 0) < time()) {
            throw new RuntimeException('Token expired.');
        }

        return $claims;
    }

    private function encode(array $header, array $payload): string
    {
        $segments = [$this->b64(json_encode($header)), $this->b64(json_encode($payload))];
        $segments[] = $this->sign(implode('.', $segments));
        return implode('.', $segments);
    }

    private function sign(string $data): string
    {
        $secret = config('jwt.secret');
        if (!$secret) {
            throw new RuntimeException('JWT_SECRET is not configured.');
        }

        return $this->b64(hash_hmac('sha256', $data, $secret, true));
    }

    private function b64(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }

    private function b64decode(string $value): string
    {
        return base64_decode(strtr($value, '-_', '+/'));
    }
}

