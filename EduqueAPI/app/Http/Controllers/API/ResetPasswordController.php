<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Models\User;
//use PragmaRX\Otp\Otp;
use Illuminate\Support\Facades\Hash;


class ResetPasswordController extends Controller
{
    private $otp;

    public function __construct(){
        //$this->otp = new Otp();
    }

    public function passwordReset(Request $request){
        try {
            $user = User::where('email',$request->email)->first();
            if ($user == null) {
                # code...
                return response()->json(["message"=>"user does not exist"], 404);
            }
            //$last_otp = $user->otps()->orderBy('created_at','desc')->first();
            $user->update(['password' => Hash::make($request->password)]);
            //error_log($last_otp);
            return response()->json(["message"=>"password update"], 200);
            
        } catch (\Throwable $th) {
            //throw $th;
            error_log($th->getMessage());
            return response()->json(["message"=>$th->getMessage()], 500);
        }
        
    }
    public function passwordReset2(Request $request){
        try {
            // Assurez-vous d'avoir l'utilisateur correctement authentifié
            $user = auth()->user();
    
            if ($user) {
                // Vérifiez si l'ancien mot de passe correspond
                if (Hash::check($request->input('old_password'), $user->password)) {
                    // Mettez à jour le mot de passe
                    $user->update(['password' => Hash::make($request->input('new_password'))]);
                    return response()->json(["message" => "password update"], 200);
                } else {
                    // L'ancien mot de passe est incorrect
                    return response()->json(["message" => "old password is incorrect"], 400);
                }
            } else {
                // L'utilisateur n'est pas correctement authentifié
                return response()->json(["message" => "user not authenticated"], 401);
            }
        } catch (\Throwable $th) {
            error_log($th->getMessage());
            return response()->json(["message" => $th->getMessage()], 500);
        }
    }
    
    
    

    
}
