<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\Request;
use Otp;
use App\Models\User;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;

class EmailVerificationController extends Controller
{

    private $otp;
    public function __construct(){
        $this->otp = new Otp;
    }

    public function sendEmailVerification(Request $request){
        $request->user()->notify(new EmailVerificationNotification());
        $success['success']=true;
        return response()->json($success,200);
    }
    public function email_verification(EmailVerificationRequest $request){
        $otp = $this->otp->validate($request->email,$request->otp);
        if(!$otp2->status){
            return response()->json(['error' => $otp2],401);
        }
        $user = User:: where('email',$request->email)->first();
            $user->update(['email_verified_at' => now()]);
            $success['success'] = true;
            return response()->json($success,200);
    }
}
