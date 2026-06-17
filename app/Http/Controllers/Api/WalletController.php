<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;

class WalletController extends Controller
{
    public function show() { return auth()->user()->wallet; }
    public function transactions() { $walletId = auth()->user()->wallet->id; return Transaction::where('from_wallet_id', $walletId)->orWhere('to_wallet_id', $walletId)->latest()->paginate(); }
}

