<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller {
    public function login( Request $request ) {
        $user = User::where( 'phone', $request->phone )->first();
        if ( $user ) {
            $user = User::where( 'mdp', $request->mdp )
            ->where( 'phone', $request->phone )
            ->first();

            if ( $user ) {
                $credentials = $request->validate( [
                    'phone' => 'required',
                    'mdp' => 'required',
                ] );

                $token = JWTAuth::fromUser( $user );
                return response()->json( [ 
                    'token' => $token,
                    'phone' => true,
                    'mdp' => true,
                ], 200 );
            } else {
                return [
                    'phone' => true,
                    'mdp' => false
                ];
            }
        } else {
            return [
                'phone' => false,
                'mdp' => false
            ];
        }

    }

    protected function respondWithToken( $token ) {
        return response()->json( [
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
        ] );
    }
}
