<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CommunityController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\PortfolioController;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\SkillListingController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Middleware\JwtMiddleware;
use App\Http\Middleware\RoleMiddleware;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
    Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:10,1');
    Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/auth/reset-password', [AuthController::class, 'resetPassword']);

    Route::middleware([JwtMiddleware::class])->group(function () {
        Route::get('/me', [AuthController::class, 'me']);
        Route::put('/me', [AuthController::class, 'updateProfile']);
        Route::apiResource('/skill-listings', SkillListingController::class);
        Route::get('/skills/search', [SkillListingController::class, 'search']);
        Route::apiResource('/bookings', BookingController::class)->only(['index', 'store', 'show', 'update']);
        Route::post('/bookings/{booking}/complete', [BookingController::class, 'complete']);
        Route::get('/wallet', [WalletController::class, 'show']);
        Route::get('/transactions', [WalletController::class, 'transactions']);
        Route::apiResource('/projects', ProjectController::class);
        Route::post('/projects/{project}/apply', [ProjectController::class, 'apply']);
        Route::post('/projects/{project}/leave', [ProjectController::class, 'leave']);
        Route::post('/projects/{project}/contributions', [ProjectController::class, 'contribute']);
        Route::get('/portfolio/{username}', [PortfolioController::class, 'show']);
        Route::get('/community', [CommunityController::class, 'index']);
        Route::post('/questions', [CommunityController::class, 'question']);
        Route::post('/answers', [CommunityController::class, 'answer']);
        Route::post('/tutorials', [CommunityController::class, 'tutorial']);
        Route::get('/messages/{thread}', [MessageController::class, 'thread']);
        Route::post('/messages', [MessageController::class, 'send']);
        Route::get('/notifications', [MessageController::class, 'notifications']);

        Route::middleware([RoleMiddleware::class . ':moderator,admin'])->group(function () {
            Route::get('/moderation/reports', [AdminController::class, 'reports']);
            Route::post('/moderation/reports/{report}/resolve', [AdminController::class, 'resolveReport']);
        });

        Route::middleware([RoleMiddleware::class . ':admin'])->prefix('admin')->group(function () {
            Route::get('/analytics', [AdminController::class, 'analytics']);
            Route::get('/users', [AdminController::class, 'users']);
            Route::post('/users/{user}/ban', [AdminController::class, 'banUser']);
            Route::post('/treasury/mint', [AdminController::class, 'mintTreasury']);
        });
    });
});

