<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;

class RatingController extends Controller
{
    public function submitRating(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|between:1,5', // Validez que la note est un entier entre 1 et 5
        ]);

        if ($validator->fails()) {
            return response()->json(['error' => 'Invalid rating'], 400); // Répondez avec une erreur si la validation échoue
        }

        // Récupérez l'utilisateur actuellement authentifié (vous devez gérer l'authentification)
        $user = auth()->user();

        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Enregistrez la note dans la base de données
        $user->update(['note_app' => $request->rating]);

        return response()->json(['message' => 'Rating submitted successfully'], 200);
    }

    public function getUserRating($id)
    {
        // Vous devrez obtenir la note de l'utilisateur à partir de la base de données, en supposant que vous avez une colonne 'note_app' dans la table des utilisateurs
        $user = User::find($id);
        if (!$user) {
            return response()->json(['error' => 'Utilisateur non trouvé'], 404);
        }

        return response()->json(['rating' => $user->note_app]);
    }

    public function getUsersWithRating()
    {
        $users = User::where('note_app', '>', 0)->get();

        return response()->json($users);
    }


}
