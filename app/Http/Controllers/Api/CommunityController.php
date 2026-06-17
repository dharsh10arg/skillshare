<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Answer;
use App\Models\Question;
use App\Models\Tutorial;
use App\Services\EconomyService;
use Illuminate\Http\Request;

class CommunityController extends Controller
{
    public function index() { return ['questions' => Question::latest()->limit(20)->get(), 'tutorials' => Tutorial::latest()->limit(20)->get()]; }
    public function question(Request $request) { return Question::create($request->validate(['title' => ['required'], 'body' => ['required'], 'tags' => ['array']]) + ['user_id' => auth()->id()]); }
    public function answer(Request $request, EconomyService $economy) { $answer = Answer::create($request->validate(['question_id' => ['required', 'exists:questions,id'], 'body' => ['required']]) + ['user_id' => auth()->id()]); $economy->rewardCommunity(auth()->user(), 'helpful_answer'); return $answer; }
    public function tutorial(Request $request, EconomyService $economy) { $tutorial = Tutorial::create($request->validate(['title' => ['required'], 'body' => ['required'], 'tags' => ['array']]) + ['user_id' => auth()->id(), 'status' => 'published']); $economy->rewardCommunity(auth()->user(), 'tutorial_upload'); return $tutorial; }
}

