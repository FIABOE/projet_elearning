<?php

namespace App\Http\Controllers;

use Illuminate\Support\Carbon;
use Illuminate\Http\Request;
use App\Models\Quiz;
use App\Models\filiere;
use App\Models\user;
use App\Models\QuizResult;
use App\Models\Question;
use App\Models\QuestionResult;
use Illuminate\Support\Facades\Validator; // Importez la classe Validator
use Illuminate\Validation\Rule;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class QuizController extends Controller
{
    //Ajout
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'filiere_id' => ['required_without:filiere_libelle', 'exists:filieres,id'],
            'filiere_libelle' => ['required_without:filiere_id'],
            'question' => 'required',
            'niveau' => 'required|string',
            'options' => 'required|array',
            'options.*' => 'string',
            'correct_option' => [
            'required',
                function ($attribute, $value, $fail) use ($request) {
                    $options = $request->input('options');

                    if (!is_array($options)) {
                        $fail("Les options de réponse doivent être fournies sous forme de tableau.");
                        return;
                    }
                    if (!in_array($value, $options)) {
                        $fail("La réponse correcte doit être l'une des options fournies.");
                    }
                },
            ],
            'score' => 'required|numeric', // Ajout de la validation du score
        ], [
            'filiere_id.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'filiere_id.exists' => 'L\'ID de la filière n\'existe pas dans la base de données.',
            'filiere_libelle.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'question.required' => 'La question est requise.',
            'options.required' => 'Les options de réponse sont requises.',
            'niveau.required' => 'Le niveau est requis.',
            'options.array' => 'Les options de réponse doivent être fournies sous forme de tableau.',
            'options.*.string' => 'Chaque option de réponse doit être une chaîne de caractères.',
            'correct_option.required' => 'La réponse correcte est requise.',
            'correct_option.*' => 'La "correct_option" doit être l\'une des options fournies.',
            'score.required' => 'Le score est requis.', // Message d'erreur pour le score
            'score.numeric' => 'Le score doit être un nombre.', // Message d'erreur pour le score
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        $data = $validator->validated();

        if (array_key_exists('filiere_libelle', $data)) {
            $filiere = Filiere::where('libelle', $data['filiere_libelle'])->first();
            if (!$filiere) {
                return response()->json(['error' => 'La filière spécifiée n\'existe pas.'], 400);
            }
            $data['filiere_id'] = $filiere->id;
            unset($data['filiere_libelle']);
        }
        $user = auth()->user();
        $data['user_id'] = $user->id;
        $data['role_user'] = $user->role;

        try {
            $quiz = Quiz::create($data);
        } catch (QueryException $e) {
            if ($e->errorInfo[1] === 1062) {
                return response()->json(['error' => 'Ce quiz existe déjà dans la base de données.'], 400);
            }
        }

        if ($quiz) {
            return response()->json(['message' => 'Quiz créé avec succès', 'quiz' => $quiz, 'score' => $data['score']], 201);
        } else {
            return response()->json(['error' => 'Échec de la création du quiz'], 500);
        }
    }


    ///supression
    public function destroy($id)
    {
        $quiz = Quiz::find($id);
        if (!$quiz) {
            return response()->json(['error' => 'Quiz non trouvé'], 404);
        }
        $quiz->delete();
        return response()->json(['message' => 'Quiz supprimé avec succès'], 200);
    }

    ///modification 
    public function update(Request $request, $id)
    {
        $quiz = Quiz::find($id);
        if (!$quiz) {
            return response()->json(['error' => 'Quiz non trouvé'], 404);
        }
        $validator = Validator::make($request->all(), [
            'filiere_id' => ['required_without:filiere_libelle', 'exists:filieres,id'],
            'filiere_libelle' => ['required_without:filiere_id'],
            'question' => 'required',
            'niveau' => 'required|string',
            'options' => 'required|array',
            'options.*' => 'string',
            'correct_option' => [
                'required',
                function ($attribute, $value, $fail) use ($request) {
                    $options = $request->input('options');
            
                    if (is_array($options) && !empty($options) && !in_array($value, $options)) {
                        $fail("La réponse correcte doit être l'une des options fournies.");
                    }
                },
            ],
            'score' => 'required|numeric', // Ajout de la validation du score
        ], [
            'filiere_id.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'filiere_id.exists' => 'L\'ID de la filière n\'existe pas dans la base de données.',
            'filiere_libelle.required_without' => 'L\'ID de la filière ou le libellé de la filière est requis.',
            'question.required' => 'La question est requise.',
            'options.required' => 'Les options de réponse sont requises.',
            'niveau.required' => 'Le niveau est requis.',
            'options.array' => 'Les options de réponse doivent être fournies sous forme de tableau.',
            'options.*.string' => 'Chaque option de réponse doit être une chaîne de caractères.',
            'correct_option.required' => 'La réponse correcte est requise.',
            'score.required' => 'Le score est requis.', // Message d'erreur pour le score
            'score.numeric' => 'Le score doit être un nombre.', // Message d'erreur pour le score
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        $data = $validator->validated();
    
        if (array_key_exists('filiere_libelle', $data)) {
            $filiere = Filiere::where('libelle', $data['filiere_libelle'])->first();
            if (!$filiere) {
                return response()->json(['error' => 'La filière spécifiée n\'existe pas.'], 400);
            }
            $data['filiere_id'] = $filiere->id;
            unset($data['filiere_libelle']);
        }
    
        // Mettez à jour le quiz en utilisant les données validées
        $quiz->update($data);

        return response()->json(['message' => 'Quiz mis à jour avec succès', 'quiz' => $quiz, 'score' => $data['score']], 200);
    }

    //listes des quiz
    public function index()
    {
        $quizzes = Quiz::with('filiere')->get();
    
        $quizData = $quizzes->map(function ($quiz) {
            $filiereLibelle = $quiz->filiere ? $quiz->filiere->libelle : null; // Vérifiez si la filière est null
            return [
                'id' => $quiz->id,
                'filiere' => $filiereLibelle, // Utilisez la variable $filiereLibelle
                'question' => $quiz->question,
                'options' => $quiz->options,
                'correct_option' => $quiz->correct_option,
                'score' => $quiz->score,
                'updated_at' => $quiz->updated_at,
                'niveau' => $quiz->niveau,
                'user_id' => $quiz->user_id,
                'role_user' => $quiz->role_user,
                'created_at' => $quiz->created_at,
            ];
        });
        
    
        return response()->json(['success' => true, 'data' => $quizData]);
    }
    
    
    //Quiz par filliere ett niveaux
    public function getQuizByFiliereAndNiveau($filiere_id, $niveau)
    { 
        try {
            $quizs = Quiz::where('filiere_id', $filiere_id)
            ->where('niveau', $niveau)
            ->get();
            if ($quizs->isEmpty()) {
                info('Aucun quiz trouvé pour cette filière et ce niveau.');
                return response()->json([
                    'success' => false,
                    'message' => 'Aucun quiz trouvé pour cette filière et ce niveau.',
                    'data' => [],
                ],404);
            }
            return response()->json([
                'success' => true,
                'data' => $quizs,
            ],200);
        } catch (\Exception $e) {
            error_log($e);
            return response()->json([
              'success' => false,
              'message' => 'Une erreur s\'est produite lors de la récupération des quiz.',
              'error' => $e->getMessage(),
            ], 500);
        }
    }

    //liste des niveaux
    public function getNiveaux()
    {
       $niveaux = Quiz::whereNotNull('niveau')->distinct('niveau')->pluck('niveau')->all();
       return response()->json([
        'success' => true,
        'data' => $niveaux,
       ], 200);
    }
    
    //Quiz par id de filliere
    public function getQuizByFiliere($filiere_id)
    {
        try {
            $quizs = Quiz::where('filiere_id', $filiere_id)->get();
            
            if ($quizs->isEmpty()) {
                //info('Aucun quiz trouvé pour cette filière.');
                return response()->json([
                    'success' => true,
                    'message' => 'Aucun quiz trouvé pour cette filière.',
                    'data' => [],
                ], 200);
            }
            return response()->json([
                'success' => true,
                'data' => $quizs,
            ], 200);
        } catch (\Exception $e) {
            error_log($e);
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des quiz.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function getNiveau()
    {
        $user = Auth::user(); // Récupérez l'utilisateur authentifié

        $niveau = $user->niveau; // Récupérez le niveau choisi par l'utilisateur depuis la base de données

        return response()->json([
            'success' => true,
            'niveau' => $niveau,
        ], 200);
    }



    public function getQuizzesByModerator($moderateurId)
   {
        try {
           // Récupérer les quiz associés à un modérateur
            $quizzes = Quiz::where('user_id', $moderateurId)->get();

            return response()->json([
                'success' => true,
                'quizzes' => $quizzes,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur s\'est produite lors de la récupération des quiz.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

   //Sauvegarde des questions
    public function saveQuestionResult(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'moyenne_generale' => 'required',
                'total_score' => 'required',
                'niveau' => 'required',
                'nombre_questions_repondues' => 'required',
                'nombre_questions_reussies' => 'required',  // Ajout du champ
                'nombre_questions_echouees' => 'required',
                'temps_passe' => 'required',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erreur de validation',
                    'errors' => $validator->errors(),
                ], 400);
            }

            $quizResult = QuizResult::create([
                'user_id' => auth()->user()->id,
                'niveau' => $request->input('niveau'),
                'total_score' => $request->input('total_score'),
                'nombre_questions_repondues' => $request->input('nombre_questions_repondues'),
                'nombre_questions_reussies' => $request->input('nombre_questions_reussies'),  
                'nombre_questions_echouees' => $request->input('nombre_questions_echouees'),  
                'moyenne_generale' => $request->input('moyenne_generale'),
                'temps_passe' => $request->input('temps_passe'),
            ]);

            return response()->json([
                'message' => 'Données sauvegardées',
            ], 200);
        } catch (\Throwable $th) {
            //error_log($th);
            return response()->json([
                'message' => 'Erreur lors de la sauvegarde des données',
                'error' => $th->getMessage(),
            ], 500);
        }
    }

    public function getLastAverage()
    {
        try {
            $userId = auth()->user()->id;
            $result = QuizResult::where('user_id',$userId)->orderBy('created_at','desc')->get()->take(1);
            return response()->json([
                'result' => $result,
            ]);
        } catch (\Throwable $th) {
            //error_log($th);
            return response()->json([
                'message' => 'Erreur lors de la récupération de la moyenne',
                'error' => $th->getMessage(),
            ], 500);
        }
    }

    public function getObjectif()
    {
        try {
            $user = auth()->user();
            $dateDebutSemaine = Carbon::now()->startOfWeek();
            $results = QuizResult::where('user_id', $user->id)
                ->where('created_at', '>=', $dateDebutSemaine)
                ->get();

                $quota = 0;
                foreach ($results as $result) {
                    $quota = $quota + ($result->temps_passe / 60);
                }
            return response()->json([
                'duree' => $user->objectif->duree,
                'quota' => $quota,
            ], 200);
        } catch (\Throwable $th) {
           // error_log($th);
            return response()->json([
                'message' => 'Erreur lors de la récupération des objectifs',
                'error' => $th->getMessage(),
            ], 500);
        }
    }

}