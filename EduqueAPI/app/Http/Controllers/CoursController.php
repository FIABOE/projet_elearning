<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use App\Models\Cours;
use App\Models\filiere;
use App\Models\Favori;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;


class CoursController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'filiere_id' => ['required_without:filiere_libelle', 'exists:filieres,id'],
            'filiere_libelle' => ['required_without:filiere_id'],
            'pdf_file' => ['required', 'mimes:pdf'],
            // Autres règles de validation...
        ], [
            'filiere_id.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'filiere_id.exists' => 'L\'ID de la filière n\'existe pas dans la base de données.',
            'filiere_libelle.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'pdf_file.required' => 'Le fichier PDF est requis.',
            'pdf_file.mimes' => 'Le fichier doit être un fichier PDF.',
            // Messages d'erreur pour les autres règles...
        ]);
    
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
        $data = $validator->validated();
        if (array_key_exists('filiere_libelle', $data)) {
            // Si le libellé de la filière est fourni, recherchez l'ID correspondant
            $filiere = Filiere::where('libelle', $data['filiere_libelle'])->first();
            if (!$filiere) {
                return response()->json(['error' => 'La filière spécifiée n\'existe pas.'], 400);
            }
            $data['filiere_id'] = $filiere->id;
            unset($data['filiere_libelle']); // Supprimez le libellé de la filière pour éviter une erreur
        }
        // Obtenez l'utilisateur actuellement authentifié
        $user = Auth::user();
        // Effectuez la création du cours à ce niveau, après avoir géré le libellé de la filière
        $pdfFile = $request->file('pdf_file');
        $pdfFileName = time() . '_' . $pdfFile->getClientOriginalName();

        if (Storage::disk('public')->exists('pdf_cours/' . $pdfFileName)) {
            return response()->json(['error' => 'Ce fichier PDF existe déjà dans la base de données.'], 400);
        }                   
    
        $existingCours = Cours::where('filiere_id', $data['filiere_id'])
            ->where('pdf_file', 'pdf_cours/' . $pdfFileName)
            ->first();
    
        if ($existingCours) {
            return response()->json(['error' => 'Ce cours existe déjà pour cette filière.'], 400);
        }
    
        $pdfFile->storeAs('pdf_cours', $pdfFileName, 'public');
        /*$cours = Cours::create([
            'pdf_file' => 'pdf_cours/' . $pdfFileName,
            'pdf_file_name' => $pdfFile->getClientOriginalName(),
            'filiere_id' => $data['filiere_id'],
            'user_id' => $user->id, // Ajoutez l'ID de l'utilisateur actuellement authentifié
            'role_user' => $user->role, // Ajoutez le rôle de l'utilisateur actuellement authentifié
        ]);*/
        $cours = Cours::create([
            'pdf_file' => 'pdf_cours/' . $pdfFileName,
            'pdf_file_name' => pathinfo($pdfFile->getClientOriginalName(), PATHINFO_FILENAME),
            'nom_du_cours' => pathinfo($pdfFile->getClientOriginalName(), PATHINFO_FILENAME), // ← AJOUTE CETTE LIGNE
            'filiere_id' => $data['filiere_id'],
            'user_id' => $user->id,
            'role_user' => $user->role,
        ]);
                
        if ($cours) {
            return response()->json(['message' => 'Cours ajouté avec succès.', 'cours' => $cours], 201);
        } else {
            return response()->json(['error' => 'Échec de la création du cours.'], 500);
        }
    }
    public function update(Request $request, $id)
    {
        $cours = Cours::find($id);
    
        if (!$cours) {
            return response()->json(['error' => 'Cours non trouvé.'], 404);
        }
    
        $validator = Validator::make($request->all(), [
            'pdf_file' => ['mimes:pdf'],
            // Autres règles de validation...
        ], [
            'pdf_file.mimes' => 'Le fichier doit être un fichier PDF.',
            // Messages d'erreur pour les autres règles...
        ]);
    
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
    
        $data = $validator->validated();
    
        if ($request->hasFile('pdf_file')) {
            // Gérez le fichier PDF si un nouveau fichier est envoyé
            $pdfFile = $request->file('pdf_file');
            $pdfFileName = time() . '_' . $pdfFile->getClientOriginalName();
    
            // Supprimez l'ancien fichier PDF s'il existe
            if (Storage::disk('public')->exists($cours->pdf_file)) {
                Storage::disk('public')->delete($cours->pdf_file);
            }
    
            $pdfFile->storeAs('pdf_cours', $pdfFileName, 'public');
            $cours->pdf_file = 'pdf_cours/' . $pdfFileName;
            $cours->pdf_file_name = $pdfFile->getClientOriginalName();
        }
    
        // Vous pouvez ajouter d'autres champs à mettre à jour ici
        // Exemple : $cours->autre_champ = $request->autre_champ;
    
        if ($cours->save()) {
            return response()->json(['message' => 'Cours mis à jour avec succès.', 'cours' => $cours], 200);
        } else {
            return response()->json(['error' => 'Échec de la mise à jour du cours.'], 500);
        }
    }
    



    public function destroy($id)
    {
        // Recherchez le cours par ID
        $cours = Cours::find($id);

        if (!$cours) {
            return response()->json(['error' => 'Cours non trouvé'], 404);
        }

        // Supprimez les favoris associés à ce cours d'abord
        $cours->favoris()->delete();

        // Supprimez le fichier PDF associé, s'il existe
        if (Storage::disk('public')->exists($cours->pdf_file)) {
            Storage::disk('public')->delete($cours->pdf_file);
        }

        // Supprimez le cours de la base de données
        $cours->delete();
        return response()->json(['message' => 'Cours supprimé avec succès'], 200);
    }

    //listes des cours
    public function index()
    {
        $cours = Cours::with('filiere')->get();
        $coursData = $cours->map(function ($cours) {
            return [
                'id' => $cours->id,
                'filiere' => $cours->filiere->libelle, // Libellé de la filière
                'pdf_file' => $cours->pdf_file,
                'pdf_file_name' => $cours->pdf_file_name,
                'user_id' => $cours->user_id,
                'role_user' => $cours->role_user,
                'created_at' => $cours->created_at,
                'updated_at' => $cours->updated_at,
            ];
        });
        return response()->json(['success' => true, 'data' => $coursData]);
    }
 
    public function showPdf($pdfFileName)
    {
        // Recherchez le nom du fichier PDF correspondant à partir du nom de fichier donné
        $cours = Cours::where('pdf_file_name', $pdfFileName)->first();
        if (!$cours) {
            // Si le cours n'est pas trouvé, renvoyez une réponse d'erreur
            return response()->json(['message' => 'Cours introuvable'], 404);
        }
        // Récupérez le chemin complet du fichier PDF à partir du modèle Cours
        $pdfFilePath = $cours->pdf_file = 'pdf_cours/' . $pdfFileName;
        // Vérifiez si le fichier existe dans le système de stockage (par exemple, le stockage local)
        if (Storage::exists($pdfFilePath)) {
            // Si le fichier existe, renvoyez le fichier PDF comme réponse
            return Storage::download($pdfFilePath, $pdfFileName, ['Content-Type' => 'application/pdf']);
        } else {
            // Si le fichier n'existe pas, renvoyez une réponse d'erreur
            return response()->json(['message' => 'Fichier PDF introuvable'], 404);
        }
    }

    //fonction pour afficher la liste des cours selon la filiere
    public function getCoursByFiliere($filiere_id)
    {
        try {
            $cours = Cours::where('filiere_id', $filiere_id)->get();
        
            if ($cours->isEmpty()) {
                //info('Aucun cours trouvé pour cette filière.');
                return response()->json([
                    'success' => true,
                    'message' => 'Aucun cours trouvé pour cette filière.',
                    'data' => [],
                ], 200);
            }
            return response()->json([
                'success' => true,
                'data' => $cours,
            ], 200);
        } catch (\Exception $e) {
            error_log($e);
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des cours.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    //fonction pour afficher les cours associé à un user
    public function getCoursByModerator($moderateurId)
    {
        try {
            // Récupérer les cours associés à un modérateur
            $cours = Cours::where('user_id', $moderateurId)->get();
            return response()->json([
                'success' => true,
                'cours' => $cours,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des cours.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
    

    
    