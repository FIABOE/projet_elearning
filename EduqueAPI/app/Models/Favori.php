<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Favori extends Model
{

    use HasFactory;
    
    protected $table = 'favoris'; // Spécifiez le nom de la table

    protected $fillable = ['user_id', 'cours_id'];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function cours()
    {
        return $this->belongsTo(Cours::class, 'cours_id');
    }
}
