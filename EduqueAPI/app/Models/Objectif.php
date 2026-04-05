<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Objectif extends Model
{
    use HasFactory;

    protected $table = 'objectifs'; 

    protected $fillable = [
        'libelle', 
        'user_id', 
        'role_user',
        'duree'
    ];

      
    public function user()
    {
      return $this->belongsTo(User::class);
    }

}
