<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\User;
use App\Services\EconomyService;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function index() { return Booking::where('student_id', auth()->id())->orWhere('teacher_id', auth()->id())->latest()->paginate(); }
    public function store(Request $request) { $data = $request->validate(['teacher_id' => ['required', 'exists:users,id'], 'skill_listing_id' => ['required', 'exists:skill_listings,id'], 'duration_minutes' => ['required', 'in:30,60,120'], 'scheduled_at' => ['nullable', 'date'], 'notes' => ['nullable', 'string']]); return Booking::create($data + ['student_id' => auth()->id(), 'status' => 'requested']); }
    public function show(Booking $booking) { $this->authorizeBooking($booking); return $booking; }
    public function update(Request $request, Booking $booking) { $this->authorizeBooking($booking); $booking->update($request->validate(['status' => ['required', 'in:accepted,scheduled,cancelled'], 'scheduled_at' => ['nullable', 'date']])); return $booking; }
    public function complete(Booking $booking, EconomyService $economy) { $this->authorizeBooking($booking); $economy->completeTeachingSession(User::findOrFail($booking->teacher_id), User::findOrFail($booking->student_id), $booking->duration_minutes); $booking->update(['status' => 'completed']); return $booking; }
    private function authorizeBooking(Booking $booking): void { abort_unless(in_array(auth()->id(), [$booking->student_id, $booking->teacher_id], true), 403); }
}

