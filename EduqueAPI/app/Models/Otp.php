<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

class Otp extends Model
{
    use HasFactory;

    protected $fillable = ['code', 'user_id', 'expired_at'];
    


    public function user()
    {
       return $this->belongsTo(User::class);
    }




}
