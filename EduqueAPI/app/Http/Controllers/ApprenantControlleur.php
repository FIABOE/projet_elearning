<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;

class ApprenantControlleur extends Controller
{
    public function getAllApprenants()
    {
        // Sélectionnez tous les utilisateurs ayant le rôle "user" et spécifiez les colonnes à sélectionner
        $apprenants = User::where('role', 'user')->select('id',
        'name', 
        'surname', 
        'email',
        'created_at',
        'dateNais',
        'filiere_id',
        'objectif_id',
        'note_app')->get();
    
        // Retournez la liste des apprenats sous forme de réponse JSON
        return response()->json([
            'success' => true,
            'apprenants' => $apprenants,
        ]);
    }

}