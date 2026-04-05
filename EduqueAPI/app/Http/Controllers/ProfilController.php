<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Profil;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;


class ProfilController extends Controller
{
    /**
     * Store the user's profile information.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        // Valider les données de la demande
            $validator = Validator::make($request->all(), [
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'pseudo' => 'required|string|max:255',
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
        $user = auth()->user();
        if (!$user) {
            // L'utilisateur n'est pas authentifié, gérer l'erreur en conséquence
            return response()->json(['error' => 'Utilisateur non authentifié.'], 401);
        }
        try {
            // Rechercher s'il existe déjà un profil pour cet utilisateur   
            $profil = Profil::where('user_id', $user->id)->first();
            if (!$profil) {
                // Si aucun profil n'existe, créez-en un nouveau
                $profil = new Profil();
                $profil->user_id = $user->id;
            }
            // Gérer le téléchargement de l'avatar
            if ($request->hasFile('avatar')) {
                $avatar = $request->file('avatar');
                $avatarPath = $avatar->store('avatars', 'public');
                $profil->avatar = $avatarPath;
            }

            // Mettre à jour le champ "pseudo" dans le profil
            $profil->pseudo = $request->input('pseudo');
            $profil->save();

            return response()->json([
                'message' => 'Profil mis à jour avec succès.',
                'data' => $profil,
            ], 200);
        } catch (\Exception $e) {
            // Enregistrer l'erreur dans les journaux
            error_log($e);
            return response()->json(['error' => 'Une erreur est survenue lors de la mise à jour du profil.'], 500);
        }
    }

    public function getUserProfile(Request $request)
    {
        // Récupérez l'utilisateur authentifié à partir du token d'authentification
        $user = $request->user();
        if ($user) {
            // L'utilisateur est authentifié, récupérez les informations du profil
            $profil = $user->profil;
            if ($profil) {
                // Retournez les données du profil
                return response()->json([
                    'success' => true,
                    'pseudo' => $profil->pseudo,
                    'avatar' => $profil->avatar,
                ]);
            }
        }

        // Si l'utilisateur n'est pas trouvé ou s'il n'a pas de profil, retournez une réponse appropriée
        return response()->json([
            'success' => false,
            'message' => 'Profil introuvable',
        ], 404);
    }


    public function updateUserAndProfile(Request $request)
    {
        // Récupérez l'utilisateur connecté
        $user = auth()->user();
        // Validez les données de la demande pour la mise à jour de l'utilisateur
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'surname' => 'sometimes|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'dateNais' => 'sometimes|date_format:Y-m-d|before:-15 years',
            'email' => 'sometimes|email|max:255',
            'avatar' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048', // Ajoutez cette règle pour l'avatar
            'pseudo' => 'sometimes|string|max:255',
            // Ajoutez d'autres règles de validation au besoin
         ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        // Récupérez les données de mise à jour pour l'utilisateur
        $userData = array_filter($request->only(['name', 'surname', 'dateNais', 'email']));
    
        // Parcourez les données et conservez les anciennes valeurs si les nouveaux champs sont vides
        foreach ($userData as $key => $value) {
            if (empty($value)) {
                $userData[$key] = $user->$key; // Utilisez l'ancienne valeur
            }
        }
    
        // Mettez à jour les attributs de l'utilisateur avec les nouvelles données
        $user->update($userData);

        // Validez les données de la demande pour la mise à jour du profil
        $validator = Validator::make($request->all(), [
            'pseudo' => 'sometimes|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
    
        // Récupérez le profil de l'utilisateur (ou créez-en un s'il n'en a pas)
        $profil = $user->profil ?: new Profil();

        // Mettez à jour le pseudo du profil
        $pseudo = $request->input('pseudo');
        if (!empty($pseudo)) {
            $profil->pseudo = $pseudo;
        }

        // Gérer le téléchargement de l'avatar
        if ($request->hasFile('avatar')) {
            $avatar = $request->file('avatar');
            $avatarPath = $avatar->store('avatars', 'public');
            $profil->avatar = $avatarPath;
        }

        // Sauvegardez les modifications du profil
        $profil->save();

        return response()->json([
            'message' => 'Informations de l\'utilisateur et du profil mises à jour avec succès.',
            'user' => $user,
            'profil' => $profil,
        ], 200);
    }
}