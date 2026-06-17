<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SkillListing;
use Illuminate\Http\Request;

class SkillListingController extends Controller
{
    public function index() { return SkillListing::with('user')->where('is_active', true)->latest()->paginate(); }
    public function search(Request $request) { return SkillListing::query()->where('title', 'like', '%' . $request->query('q') . '%')->orWhere('expertise_level', $request->query('level'))->paginate(); }
    public function store(Request $request) { return SkillListing::create($this->validated($request) + ['user_id' => auth()->id()]); }
    public function show(SkillListing $skillListing) { return $skillListing; }
    public function update(Request $request, SkillListing $skillListing) { abort_unless($skillListing->user_id === auth()->id(), 403); $skillListing->update($this->validated($request, true)); return $skillListing; }
    public function destroy(SkillListing $skillListing) { abort_unless($skillListing->user_id === auth()->id(), 403); $skillListing->delete(); return response()->noContent(); }
    private function validated(Request $request, bool $partial = false): array { return $request->validate(['skill_id' => [$partial ? 'sometimes' : 'required', 'integer'], 'title' => [$partial ? 'sometimes' : 'required', 'string'], 'description' => ['nullable', 'string'], 'duration_minutes' => ['required', 'in:30,60,120'], 'expertise_level' => ['required', 'in:beginner,intermediate,advanced,expert'], 'availability' => ['array'], 'is_active' => ['boolean']]); }
}

