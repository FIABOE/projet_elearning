<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Filiere extends Model
{
    use HasFactory;
    protected $table = 'filieres'; 

    protected $fillable = ['libelle', 'user_id', 'role_user'];

    public function cours()
    {
        return $this->hasMany(Cours::class);
    }
    public function exercices()
    {
        return $this->hasMany(Cours::class);
    }
    public function user()
    {
        return $this->belongsTo(User::class);
    }

}
