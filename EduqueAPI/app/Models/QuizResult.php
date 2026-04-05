<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizResult extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 
        'niveau', 
        'total_score',
        'nombre_questions_repondues',
        'nombre_questions_reussies', 
        'nombre_questions_echouees',  
        'moyenne_generale',
        'temps_passe'
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function niveau()
    {
        return $this->belongsTo(Quiz::class, 'niveau')->select('niveau');
    }

}
