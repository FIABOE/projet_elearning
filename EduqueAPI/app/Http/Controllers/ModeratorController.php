<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Moderateur;
use Illuminate\Support\Facades\Hash;


class ModeratorController extends Controller
{
    public function register(Request $request)
    {
        // Créez un nouvel utilisateur avec le rôle "moderateur"
        $user = new User;
        $user->name = $request->input('name');
        $user->surname = $request->input('surname');
        $user->email = $request->input('email');
        $user->password = Hash::make($request->password);
        // send email
        $user->role = 'moderateur'; 
        // Sauvegardez l'utilisateur dans la base de données
        $user->save();
        
        // Génération du jeton d'accès
        $token = $user->createToken('Myapp')->plainTextToken;
        // Associer le jeton à l'utilisateur dans la base de données
        $user->update(['remember_token' => $token]);
        // Retournez une réponse JSON avec le token
        return response()->json([
            'success' => true,
            'message' => 'Moderator registered successfully',
            'token' => $token 
        ]);
    }

    public function getAllModerators()
    {
        // Sélectionnez tous les utilisateurs ayant le rôle "moderateur" et spécifiez les colonnes à sélectionner
        $moderators = User::where('role', 'moderateur')->select('id', 'name', 'surname', 'email')->get();

        // Retournez la liste des modérateurs sous forme de réponse JSON
        return response()->json([
            'success' => true,
            'moderators' => $moderators,
        ]);
    }

    public function update(Request $request, $id)
    {
        $moderateur = User::find($id);
        if (!$moderateur) {
            return response()->json(['success' => false, 'message' => 'Modérateur non trouvé'], 404);
        }

        $request->validate([
            'name' => 'required|string',
            'surname' => 'required|string',
            'email' => 'required|email',
        ]);
        $moderateur->name = $request->input('name');
        $moderateur->surname = $request->input('surname');
        $moderateur->email = $request->input('email');
        $moderateur->save();

        return response()->json([
            'success' => true,
            'message' => 'Modérateur mis à jour avec succès',
            'data' => $moderateur,
        ], 200);
    }

    public function deactivateMod($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'Utilisateur non trouvé'], 404);
        }

        $user->deactivate(); // Appel de la méthode pour désactiver l'utilisateur

        return response()->json(['message' => 'Modérateur désactivé avec succès']);
    }
    
    public function activateMod($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['error' => 'Utilisateur non trouvé'], 404);
        }
        $user->activate(); // Appel de la méthode pour activer l'utilisateur
        return response()->json(['message' => 'Modérateur activé avec succès']);
    }





}

