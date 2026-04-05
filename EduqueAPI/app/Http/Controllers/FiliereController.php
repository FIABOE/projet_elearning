<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\filiere;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class FiliereController extends Controller
{
    public function store(Request $request)
    {
        // Définir les règles de validation
        $rules = [
            'libelle' => 'required|string|max:255|unique:filieres,libelle',
        ];
        // Valider les données
        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 400);
        }
        try {
            // Récupérer l'utilisateur actuellement authentifié
            $user = auth()->user();
            // Créer une nouvelle filière avec le libellé fourni et les données de l'utilisateur actuel
            $filiere = Filiere::create([
              'libelle' => $request->input('libelle'),
              'user_id' => $user->id, // ID de l'utilisateur actuel
              'role_user' => $user->role, // Rôle de l'utilisateur actuel
            ]);
            return response()->json([
              'success' => true,
              'message' => 'Filière ajoutée avec succès',
              'data' => $filiere,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
              'success' => false,
              'message' => 'Erreur lors de l\'ajout de la filière',
              'error' => $e->getMessage(),
            ], 400);
        }
    }
    
    public function update(Request $request, $id)
    {
        $filiere = Filiere::find($id);
        if (!$filiere) {
            return response()->json(['success' => false, 'message' => 'Filière non trouvée'], 404);
        }
        $rules = [
            'libelle' => 'required|string|max:255|unique:filieres,libelle,' . $filiere->id,
        ];
        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 400);
        }
        // Mettez à jour le libellé de la filière
        $filiere->libelle = $request->input('libelle');
        $filiere->user_id = auth()->user()->id; // Mettez à jour l'ID de l'utilisateur
        $filiere->role_user = auth()->user()->role; // Mettez à jour le rôle de l'utilisateur
        $filiere->save();
        
        return response()->json([
            'success' => true,
            'message' => 'Filière mise à jour avec succès',
            'data' => $filiere,
        ], 200);
    }
    
    public function destroy($id)
    {
        $filiere = Filiere::find($id);

        if (!$filiere) {
            return response()->json(['success' => false, 'message' => 'Filière non trouvée'], 404);
        }

        // Mettez à jour les utilisateurs qui font référence à cette filière
        User::where('filiere_id', $filiere->id)->update(['filiere_id' => null]);

        // Supprimez la filière
        $filiere->delete();

        return response()->json(['success' => true, 'message' => 'Filière supprimée avec succès'], 200);
    }

    
    public function index()
    {
        // Récupérez toutes les filières de la base de données
        $filieres = Filiere::all();

        // Vérifiez si la liste des filières est vide
        if ($filieres->isEmpty()) {
            return response()->json([
                'success' => true,
                'message' => 'Aucun élément trouvé.',
                'data' => [],
            ], 200);
        }
        // Retournez la liste des filières en tant que réponse JSON
        return response()->json([
            'success' => true,
            'data' => $filieres,
        ], 200);
    }
    
    public function getFilieresByModerateur($moderateurId)
    {
        try {
            // Récupérer les filières associées à un modérateur
            $filieres = Filiere::where('user_id', $moderateurId)->get();

            return response()->json([
                'success' => true,
                'filieres' => $filieres,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des filières.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
    public function getFiliereIdByLibelle($libelle) {
        // Recherche de la filière par libellé
        $filiere = Filiere::where('libelle', $libelle)->first();

        if ($filiere) {
            return response()->json(['id' => $filiere->id]);
        } else {
            return response()->json(['error' => 'Filière non trouvée'], 404);
        }
    }

}
    
    



    
    

