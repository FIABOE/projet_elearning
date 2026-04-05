<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
   // Dans le middleware 'admin'
public function handle($request, Closure $next)
{
    if (auth()->user()->role === 'admin') {
        return $next($request);
    }

    return response()->json(['error' => 'Unauthorized'], 403);
}

}
