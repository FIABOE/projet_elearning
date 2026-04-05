<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use App\Models\Exercices;
use App\Models\filiere;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class ExercicesController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'filiere_id' => ['required_without:filiere_libelle', 'exists:filieres,id'],
            'filiere_libelle' => ['required_without:filiere_id'],
            'pdf_file' => ['required', 'mimes:pdf'],
            'reponse' => ['required', 'mimes:pdf'], // Ajoutez la validation pour les réponses
            // Autres règles de validation...
        ], [
            'filiere_id.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'filiere_id.exists' => 'L\'ID de la filière n\'existe pas dans la base de données.',
            'filiere_libelle.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'pdf_file.required' => 'Le fichier PDF est requis.',
            'pdf_file.mimes' => 'Le fichier doit être un fichier PDF.',
            'reponse.required' => 'Le fichier PDF des réponses est requis.', // Message d'erreur pour les réponses
            'reponse.mimes' => 'Le fichier des réponses doit être un fichier PDF.', // Message d'erreur pour les réponses
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
        $reponseFile = $request->file('reponse'); // Récupérez le fichier des réponses
    
        $pdfFileName = time() . '_' . $pdfFile->getClientOriginalName();
        $reponseFileName = time() . '_' . $reponseFile->getClientOriginalName(); // Générez un nom de fichier unique pour les réponses
    
        if (Storage::disk('public')->exists('pdf_exercices/' . $pdfFileName)) {
            return response()->json(['error' => 'Ce fichier PDF existe déjà dans la base de données.'], 400);
        }
    
        if (Storage::disk('public')->exists('pdf_exercices/' . $reponseFileName)) {
            return response()->json(['error' => 'Ce fichier PDF de réponses existe déjà dans la base de données.'], 400);
        }
    
        $existingExercices = Exercices::where('filiere_id', $data['filiere_id'])
            ->where('pdf_file', 'pdf_exercices/' . $pdfFileName)
            ->first();
    
        if ($existingExercices) {
            return response()->json(['error' => 'Ce pdf_exercices existe déjà pour cette filière.'], 400);
        }
    
        $pdfFile->storeAs('pdf_exercices', $pdfFileName, 'public');
        $reponseFile->storeAs('pdf_exercices', $reponseFileName, 'public'); // Stockez le fichier des réponses
    
        $exercices = Exercices::create([
            'pdf_file' => 'pdf_exercices/' . $pdfFileName,
            'pdf_file_name' => $pdfFile->getClientOriginalName(),
            'reponse' => 'pdf_exercices/' . $reponseFileName, // Enregistrez le chemin du fichier de réponses
            'filiere_id' => $data['filiere_id'],
            'user_id' => $user->id, // Ajoutez l'ID de l'utilisateur actuellement authentifié
            'role_user' => $user->role, // Ajoutez le rôle de l'utilisateur actuellement authentifié
        ]);
    
        if ($exercices) {
            return response()->json(['message' => 'exercices ajouté avec succès.', 'exercices' => $exercices], 201);
        } else {
            return response()->json(['error' => 'Échec de la création du exercices.'], 500);
        }
    }
    
    public function destroy($id)
    {
        // Recherchez le cours par ID
        $exercices = Exercices::find($id);

        if (!$exercices) {
            return response()->json(['error' => 'Exercices non trouvé'], 404);
        }

        // Supprimez le fichier PDF associé, s'il existe
        if (Storage::disk('public')->exists($exercices->pdf_file)) {
            Storage::disk('public')->delete($exercices->pdf_file);
        }

        // Supprimez l'exercice de la base de données
        $exercices->delete();

        return response()->json(['message' => 'Exercices supprimé avec succès'], 200);
    }


    //listes des cours
    public function index()
    {
        $exercices = Exercices::with('filiere')->get();
        $exercicesData = $exercices->map(function ($exercices) {
            return [
                'id' => $exercices->id,
                'filiere' => $exercices->filiere->libelle, // Libellé de la filière
                'pdf_file' => $exercices->pdf_file,
                'pdf_file_name' => $exercices->pdf_file_name,
                'reponse' => $exercices->reponse, 
                'user_id' => $exercices->user_id,
                'role_user' => $exercices->role_user,
                'created_at' => $exercices->created_at,
                'updated_at' => $exercices->updated_at,
            ];
        });
        return response()->json(['success' => true, 'data' => $exercicesData]);
    }

    //fonction pour afficher la liste des exercices selon la filiere
    public function getExercicesByFiliere($filiere_id)
    {
        try {
            $exercices = Exercices::where('filiere_id', $filiere_id)->get();
            if ($exercices->isEmpty()) {
                //info('Aucun exercices trouvé pour cette filière.');
                return response()->json([
                    'success' => true,
                    'message' => 'Aucun exercices trouvé pour cette filière.',
                    'data' => [],
                ], 200);
            }
            return response()->json([
                'success' => true,
                'data' => $exercices,
            ], 200);
        } catch (\Exception $e) {
        error_log($e);
        return response()->json([
            'success' => false,
            'message' => 'Une erreur s\'est produite lors de la récupération des exercices.',
            'error' => $e->getMessage(),
        ], 500);
    }
}


//fonction pour afficher les exercices associé à un user
public function getExercicesByModerator($moderateurId)
{
    try {
        // Récupérer les cours associés à un modérateur
        $exercices = Exercices::where('user_id', $moderateurId)->get();

        return response()->json([
            'success' => true,
            'cours' => $exercices,
        ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des $exercices.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
