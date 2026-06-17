<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Report;
use App\Models\SkillListing;
use App\Models\Transaction;
use App\Models\User;
use App\Services\EconomyService;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function analytics() { return ['total_users' => User::count(), 'active_users' => User::whereNull('banned_at')->count(), 'sessions_completed' => Booking::where('status', 'completed')->count(), 'credits_circulated' => Transaction::sum('amount'), 'popular_skills' => SkillListing::selectRaw('title, count(*) as count')->groupBy('title')->orderByDesc('count')->limit(10)->get()]; }
    public function users() { return User::with('role', 'wallet')->paginate(); }
    public function banUser(User $user) { $user->update(['banned_at' => now()]); return $user; }
    public function reports() { return Report::latest()->paginate(); }
    public function resolveReport(Report $report) { $report->update(['status' => 'resolved', 'resolved_by' => auth()->id()]); return $report; }
    public function mintTreasury(Request $request, EconomyService $economy) { $data = $request->validate(['user_id' => ['required', 'exists:users,id'], 'amount' => ['required', 'integer', 'min:1'], 'reason' => ['required', 'string']]); $user = User::findOrFail($data['user_id']); $economy->mintFromTreasury($user->wallet, $data['amount'], 'admin_mint', $data['reason']); return $user->fresh('wallet'); }
}

