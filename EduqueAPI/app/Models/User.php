<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Notifications\ResetPasswordNotification;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;
    protected $table = 'users';
    protected $fillable = [
        'name',
        'surname',
        'dateNais',
        'email',
        'password',
        'remember_token',
        'created_at',
        'consent',
        'filiere_id',
        'objectif_id',
        'role',
        'is_active',
        'note_app',
    ];

    public function toArray()
    {
      
    return [
        'id' => $this->id,
        'Nom' => $this->surname,
        'Prenom' => $this->name,
        'Date de Naissance' => $this->asDateTime($this->dateNais)->format('d-m-Y'),
        'Date de création' => $this->asDateTime($this->created_at)->format('d-m-Y'),
        'Email' => $this->email,
        'Module' => $this->getFiliereLabel(), 
        'Objectif hebdomadaire' => $this->getObjectifLabel(),
        'filiere_id' => $this->filiere_id,
        'Note de l\'app'=> $this->note_app,
    ];

    }

    public function deactivate()
    {
        $this->update(['is_active' => false]);
    }
    
    public function activate()
    {
        $this->update(['is_active' => true]);
    }


    public function getFiliereLabel()
    {
        // Vérifiez si l'utilisateur a une filière associée
        if ($this->filiere) {
            // Récupérez le libellé de la filière associée
            return $this->filiere->libelle;
        }

        // Si l'utilisateur n'a pas de filière, retournez une valeur par défaut ou un message d'erreur
        return 'Filière non spécifiée'; // Vous pouvez personnaliser ce message
    }


    public function getObjectifLabel()
    {
        if ($this->objectif) {
            // L'objectif existe, vous pouvez accéder à sa propriété 'libelle'
            return $this->objectif->libelle;
        } else {
            // L'objectif n'existe pas, renvoyez un message ou une valeur par défaut
            return 'Objectif non spécifié'; // Vous pouvez personnaliser ce message
        }
    }

    public function filiere()
    {
        return $this->belongsTo(Filiere::class, 'filiere_id');
    }

    public function objectif()
    {
        return $this->belongsTo(Objectif::class, 'objectif_id');
    }
    
    public function profil()
    {
        return $this->hasOne(Profil::class);
    }

    public function questionResults()
    {
        return $this->hasMany(QuestionResult::class, 'user_id');
    }
    public function otps()
    {
        return $this->hasMany(Otp::class);
    }

    public function isAdmin()
    {
        return $this->role === 'admin'; 
    }

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    //public function sendPasswordResetNotification($token): void
    //{
       // $url = 'https://spa.test/reset-password?token=' . $token;
       // $this->notify(new ResetPasswordNotification($url));
    //}
}
