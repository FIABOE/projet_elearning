<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\InfoSup;


class UserInfoController extends Controller
{
    public function saveUserInfo(Request $request)
    {
        try {

            // Récupérez l'utilisateur connecté 
            $user = auth()->user();
            // Vérifiez si l'utilisateur est authentifié
            if (!$user) {
                return response()->json(['error' => 'Utilisateur non authentifié'], 401);
            }
            // Recherchez s'il existe déjà une entrée pour cet utilisateur dans la table info_sups
            $userInfo = InfoSup::where('id_user', $user->id)->first();
                // Si une entrée existe, mettez à jour les valeurs, sinon créez une nouvelle entrée
                if ($userInfo) {
                    $userInfo->update([
                        'pays' => $request->input('pays'),
                    ]);
            } else {
                $userInfo = new InfoSup([
                    'id_user' => $user->id,
                    'pays' => $request->input('pays'),
                ]);
                $userInfo->save();
            }
                // Retournez une réponse JSON pour indiquer le succès
                return response()->json(['message' => 'Informations sauvegardées avec succès']);
        } catch (\Exception $e) {
            // En cas d'erreur, retournez une réponse JSON avec le message d'erreur
            return response()->json(['error' => 'Une erreur est survenue lors de la sauvegarde des informations'], 500);
        }
    }
}
