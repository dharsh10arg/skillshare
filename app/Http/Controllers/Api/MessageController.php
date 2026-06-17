<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class MessageController extends Controller
{
    public function thread(string $thread) { return Message::where('thread_id', $thread)->latest()->paginate(); }
    public function send(Request $request) { $data = $request->validate(['recipient_id' => ['required', 'exists:users,id'], 'body' => ['required', 'string'], 'thread_id' => ['nullable', 'string']]); return Message::create($data + ['sender_id' => auth()->id(), 'thread_id' => $data['thread_id'] ?? (string) Str::uuid()]); }
    public function notifications() { return Notification::where('user_id', auth()->id())->latest()->paginate(); }
}

