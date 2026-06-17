<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Contribution;
use App\Models\Project;
use App\Models\ProjectMember;
use Illuminate\Http\Request;

class ProjectController extends Controller
{
    public function index() { return Project::latest()->paginate(); }
    public function store(Request $request) { return Project::create($this->validated($request) + ['owner_id' => auth()->id(), 'status' => 'open']); }
    public function show(Project $project) { return $project; }
    public function update(Request $request, Project $project) { abort_unless($project->owner_id === auth()->id(), 403); $project->update($this->validated($request, true)); return $project; }
    public function destroy(Project $project) { abort_unless($project->owner_id === auth()->id(), 403); $project->delete(); return response()->noContent(); }
    public function apply(Project $project) { return ProjectMember::firstOrCreate(['project_id' => $project->id, 'user_id' => auth()->id()], ['role' => 'contributor', 'status' => 'applied']); }
    public function leave(Project $project) { ProjectMember::where('project_id', $project->id)->where('user_id', auth()->id())->delete(); return response()->noContent(); }
    public function contribute(Request $request, Project $project) { return Contribution::create($request->validate(['type' => ['required', 'in:frontend,backend,testing,documentation,design'], 'description' => ['required', 'string'], 'credits_awarded' => ['integer', 'min:0']]) + ['project_id' => $project->id, 'user_id' => auth()->id()]); }
    private function validated(Request $request, bool $partial = false): array { return $request->validate(['title' => [$partial ? 'sometimes' : 'required', 'string'], 'description' => ['nullable', 'string'], 'roles_required' => ['array'], 'duration' => ['nullable', 'string'], 'skills_required' => ['array']]); }
}

