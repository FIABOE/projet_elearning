<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Cours;
use Illuminate\Support\Facades\Auth;
use App\Models\Favori;

class FavoriController extends Controller
{
    public function addFavori(Request $request)
{
    $user = Auth::user(); // Obtenez l'utilisateur connecté
    $pdfFileName = $request->input('pdf_file'); // Obtenez le nom du fichier PDF du formulaire

    // Recherchez le cours dans la base de données en utilisant le nom du fichier PDF
    $cours = Cours::where('pdf_file', $pdfFileName)->first();

    if (!$cours) {
        return response()->json(['message' => 'Cours non trouvé'], 404);
    }

    // Ajoutez le favori dans la base de données
    $favori = new Favori();
    $favori->user_id = $user->id;
    $favori->cours_id = $cours->id; // Enregistrez l'ID du cours
    $favori->save();

    return response()->json(['message' => 'Favori ajouté avec succès']);
}

    
public function removeFavori(Request $request)
{
    $user = Auth::user(); // Obtenez l'utilisateur connecté
    $coursId = $request->input('cours_id'); // Obtenez l'ID du cours à supprimer des favoris

    // Ajoutez des déclarations de débogage pour vérifier les valeurs
    // de $user->id et $coursId
    var_dump($user->id);
    var_dump($coursId);

    // Recherchez le favori dans la base de données en fonction de l'ID de l'utilisateur et de l'ID du cours
    $favori = Favori::where('user_id', $user->id)->where('cours_id', $coursId)->first();

    if ($favori) {
        // Le favori existe, supprimez-le
        $favori->delete();
        return response()->json(['message' => 'Favori supprimé avec succès'], 200);
    } else {
        // Le favori n'existe pas, renvoyez un message d'erreur
        return response()->json(['message' => 'Favori non trouvé'], 404);
    }
}

public function getFavoriteCours()
{
    $user = Auth::user(); // Obtenez l'utilisateur connecté

    // Recherchez les cours favoris de l'utilisateur actuel
    if ($user) {
        $favoris = Favori::where('user_id', $user->id)->get();
        // Reste du code pour récupérer les favoris
    } else {
        return response()->json(['message' => 'Utilisateur non trouvé'], 404);
    }
        $coursFavoris = [];
        // Parcourez chaque favori et obtenez le pdf_file du cours associé
        foreach ($favoris as $favori) {
            $cours = Cours::find($favori->cours_id);
            if ($cours) {
                $coursFavoris[] = $cours->pdf_file;
            }
        }
        return response()->json(['favoriCours' => $coursFavoris]);
    }

    public function getFavorisByUser($user_id)
    {
        $favoris = Favori::where('user_id', $user_id)->get();
        return response()->json($favoris);
    }
}