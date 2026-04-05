<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuestionResult extends Model
{
    use HasFactory;
    
    protected $fillable = ['user_id', 'question_id', 'niveau', 'selected_option', 'is_correct', 'score','temps_passe'];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function quiz()
    {
        return $this->belongsTo(Quiz::class, 'question_id', 'niveau');
    }

    public function niveau()
    {
        return $this->belongsTo(Quiz::class, 'niveau_id')->select('niveau');
    }

    
}
