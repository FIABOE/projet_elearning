<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;


class Quiz extends Model
{
    use HasFactory;

    protected $fillable = [
        'filiere_id', 
        'niveau', 
        'question', 
        'options', 
        'correct_option',  
        'user_id', 
        'role_user',
        'score'
    ];
    
    protected $casts = [ 
        'options' => 'array', 
    ];
    
    public function filiere()
    {
        return $this->belongsTo(Filiere::class, 'filiere_id', 'id');
    }


    public function user()
    {
      return $this->belongsTo(User::class);
    }

    public function questionResults()
    {
        return $this->hasMany(QuestionResult::class, 'question_id','niveau');
    }
}
