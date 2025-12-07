<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required',
            'mdp' => 'required'
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (!$user) {
            return response()->json([
                'phone' => false,
                'mdp' => false
            ]);
        }

        if ($user->mdp !== $request->mdp) {
            return response()->json([
                'phone' => true,
                'mdp' => false
            ]);
        }

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'phone' => true,
            'mdp' => true,
            'token' => $token
        ], 200);
    }


    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
        ]);
    }
}
