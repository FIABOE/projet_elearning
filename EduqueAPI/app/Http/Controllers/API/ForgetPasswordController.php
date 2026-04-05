<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
//use App\Http\Requests\Auth\ForgetPasswordRequest;
use App\Notifications\ResetPasswordVerificationNotification;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Otp;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class ForgetPasswordController extends Controller
{
    public function forgotPassword(Request $request){
        try {
            //code...
            $input = $request->only('email');
            $user = User::where('email',$input)->first();

            if($user == null)
            return response()->json([
                "message" => "user not found"
                ],404);
                
            $dateTime = Carbon::now();
            $dateTime->addMinutes(5);

            $otp = \App\Models\Otp::create([
                "code" => rand(1235, 9999),
                "user_id" => $user->id,
                "expired_at" => $dateTime
            ]);
            
           
            $user->notify(new ResetPasswordVerificationNotification($otp));
            $success['success'] = true;
            return response()->json($success,200);
        } catch (\Throwable $th) {
            //throw $th;
            error_log($th->getMessage());
            return response()->json(["message" =>  $th->getMessage()],200);

        }
    }

    public function verifyOtp(Request $request){
        try {
            //code...
            $otp = $request->input('otp'); //code otp;
            $user = User::where('email',$request->email)->first();
            if ($user == null) {
                # code...
                return response()->json(["message"=>"user does not exist"], 404);
            }
            $last_otp = $user->otps()->orderBy('created_at','desc')->first();
            if($last_otp != null){
                $date1 = strtotime($last_otp->expired_at);
                $date2 = strtotime(date('Y-m-d H:i:s'));
                if($date2 - $date1 >= -300 and $date2 - $date1 <=0 ){
                    if ($last_otp->code == $otp) {
                        # code...
                        //$user->update(['password' => Hash::make($request->password)]);
                        //$user->tokens()->delete();
                        error_log($last_otp->code);
                        error_log($otp);
                        $success['success'] = true;
                        $success['password'] = "otp verified";
                        $last_otp->expired_at =  $last_otp->created_at;
                        $last_otp->save();
                        return response()->json($success, 200);
                    }
                    return response()->json(["message"=>"incorrect otp"], 401);
                }
                return response()->json(["message"=>"otp expired, you must request a new one"], 402);
            }
            //error_log($last_otp);
            return response()->json(["message"=>"request otp first"], 403);
        } catch (\Throwable $th) {
            //throw $th;
            return response()->json(["message"=> $th->getMessage()], 500);
        }
    }

    public function resendOtp(Request $request){
        try {
            //code...
            $input = $request->only('email');
            $user = User::where('email',$input)->first();

            if($user == null)
            return response()->json([
                "message" => "user not found"
                ],404);
                
            $dateTime = Carbon::now();
            $dateTime->addMinutes(5);

            $otp = \App\Models\Otp::create([
                "code" => rand(1235, 9999),
                "user_id" => $user->id,
                "expired_at" => $dateTime
            ]);
            
           
            $user->notify(new ResetPasswordVerificationNotification($otp));
            $success['success'] = true;
            return response()->json($success,200);
        } catch (\Throwable $th) {
            //throw $th;
            error_log($th->getMessage());
            Log::info($th->getMessage());
            return response()->json(["message" => $th->getMessage()], 500);
        }
    }

    
}
