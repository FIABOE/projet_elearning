<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckIsActive
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    
    public function handle($request, Closure $next)
    {
        if (auth()->check() && !auth()->user()->is_active) {
          return response()->json(['error' => 'Votre compte est inactif.'], 403);
        }
        return $next($request);
    }
}
