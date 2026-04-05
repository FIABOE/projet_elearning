<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Objectif;
use App\Models\User;
use Illuminate\Support\Facades\Validator;

class ObjectifController extends Controller
{
    // Méthode pour extraire la durée à partir du libellé pour les minutes uniquement
    private function extractDureeFromLibelleMinutes($libelle)
    {
       preg_match('/(\d+)\s*(?:min)?(?:\s*\/\s*semaine)?/', $libelle, $matches);

       if (!empty($matches[1])) {
          return (int)$matches[1];
        }

        return 0;
    }

    // Méthode pour extraire la durée à partir du libellé qui peut contenir des heures et des minutes
    private function extractDureeFromLibelleHeuresMinutes($libelle)
    {
        preg_match('/(\d+)\s*(?:h|hrs|hour|heure)?\s*(\d*)\s*(?:min)?(?:\s*\/\s*semaine)?/', $libelle, $matches);

        $heures = !empty($matches[1]) ? (int)$matches[1] : 0;
        $minutes = !empty($matches[2]) ? (int)$matches[2] : 0;

        return $heures * 60 + $minutes;
    }

    // Méthode store
    public function store(Request $request)
    {
       // Définir les règles de validation
        $rules = [
          'libelle' => 'required|string|max:255|unique:objectifs,libelle',
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

            // Extraire la durée à partir du libellé
            $libelle = $request->input('libelle');

            // Vérifier d'abord si le libellé contient des heures et minutes
            if (preg_match('/(?:h|hrs|hour|heure)/', $libelle)) {
                $dureeEnMinutes = $this->extractDureeFromLibelleHeuresMinutes($libelle);
            } else {
                // Utiliser la méthode pour les libellés de minutes uniquement
                $dureeEnMinutes = $this->extractDureeFromLibelleMinutes($libelle);
            }

            // Créer une nouvelle objectif avec l'objectif fourni et les données de l'utilisateur actuel
            $objectif = Objectif::create([
                'libelle' => $libelle,
                'user_id' => $user->id,
                'role_user' => $user->role,
                'duree' => $dureeEnMinutes,
            ]);
            return response()->json([
                'success' => true,
                'message' => 'Objectif ajouté avec succès',
                'data' => $objectif,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'ajout de l\'objectif',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $objectif = Objectif::find($id);

            if (!$objectif) {
                return response()->json(['success' => false, 'message' => 'Objectif non trouvé'], 404);
            }
            $rules = [
                'libelle' => 'required|string|max:255|unique:objectifs,libelle,' . $objectif->id,
            ];
            $validator = Validator::make($request->all(), $rules);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors(),
                ], 400);
            }
            // Mettez à jour le libellé de l'objectif
            $objectif->libelle = $request->input('libelle');
            $objectif->user_id = auth()->user()->id; // Mettez à jour l'ID de l'utilisateur
            $objectif->role_user = auth()->user()->role; // Mettez à jour le rôle de l'utilisateur
            // Extraire la durée à partir du nouveau libellé
            if (preg_match('/(?:h|hrs|hour|heure)/', $request->input('libelle'))) {
                $dureeEnMinutes = $this->extractDureeFromLibelleHeuresMinutes($request->input('libelle'));
            } else {
                $dureeEnMinutes = $this->extractDureeFromLibelleMinutes($request->input('libelle'));
            }
            // Mettre à jour la colonne duree
            $objectif->duree = $dureeEnMinutes;

            $objectif->save();

            return response()->json([
                'success' => true,
                'message' => 'Objectif mis à jour avec succès',
                'data' => $objectif,
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de l\'objectif',
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    public function destroy($id)
    {
        $objectif = Objectif::find($id);
        if (!$objectif) {
            return response()->json(['success' => false, 'message' => 'Objectif non trouvé'], 404);
        }

        // Mettez à jour les utilisateurs qui font référence à cet objectif
        User::where('objectif_id', $objectif->id)->update(['objectif_id' => null]);

        // Supprimez l'objectif
        $objectif->delete();

        return response()->json(['success' => true, 'message' => 'Objectif supprimé avec succès'], 200);
    }


    public function index()
    {
        // Récupérez toutes les filières de la base de données
        $objectifs = Objectif::all();

        // Vérifiez si la liste des filières est vide
        if ($objectifs->isEmpty()) {
            return response()->json([
                'success' => true,
                'message' => 'Aucun élément trouvé.',
                'data' => [],
            ], 200);
        }

        // Retournez la liste des filières en tant que réponse JSON
        return response()->json([
            'success' => true,
            'data' => $objectifs,
        ], 200);
    }


    public function getObjectifsByModerateur($moderateurId)
    {
        try {
            // Récupérer les objectifs associées à un modérateur
            $objectifs = Objectif::where('user_id', $moderateurId)->get();

            return response()->json([
                'success' => true,
                'objectifs' => $objectifs,
            ]);
            } catch (\Exception $e) {
                return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des objectifs.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
    
