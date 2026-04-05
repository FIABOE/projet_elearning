<?php

namespace App\Http\Controllers;

use App\Models\Quiz;
use App\Models\Cours;
use App\Models\filiere;
use App\Models\Objectif;
use App\Models\Exercices;
use App\Models\QuizResult;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\User; 
use Carbon\Carbon;


class TotalsController extends Controller
{    
    //Nombre total de tous les ajouts (q,c,f,o,e,n)
    public function getTotals()
    {
        try {
            $totalApprenants = User::where('role', 'user')->count();
            $totalModerateurs = User::where('role', 'moderateur')->count();

            $totalFiliere = Filiere::count();
            $totalObjectif = Objectif::count();
            $totalQuiz = Quiz::count();
            $totalCours = Cours::count();
            $totalExercices = Exercices::count();

            // Ajout du nombre total de niveaux
            $nombreNiveaux = Quiz::distinct()->pluck('niveau')->count();

            return response()->json([
                'total_apprenants' => $totalApprenants,
                'total_moderateurs' => $totalModerateurs,
                'total_filiere' => $totalFiliere,
                'total_objectif' => $totalObjectif,
                'total_quiz' => $totalQuiz,
                'total_cours' => $totalCours,
                'total_exercices' => $totalExercices,
                'nombre_niveaux' => $nombreNiveaux,
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //
    public function getQuizResults($apprenantId)
    {
        try {
            // Récupérez les résultats du quiz pour l'apprenant spécifique
            $quizResults = QuizResult::where('user_id', $apprenantId)->get();

            // Regroupez les résultats par niveau
            $groupedResults = $quizResults->groupBy('niveau');

            // Calculez la moyenne faible et forte pour chaque niveau
            $processedResults = [];
            foreach ($groupedResults as $niveau => $results) {
                $minMoyenne = $results->min('moyenne_generale');
                $maxMoyenne = $results->max('moyenne_generale');

                $processedResults[] = [
                    'niveau' => $niveau,
                    'faible' => $minMoyenne,
                    'forte' => $maxMoyenne,
                ];
            }

            return response()->json($processedResults);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //
    public function getQuizglobalResults($apprenantId)
    {
        try {
            // Récupérez les résultats du quiz pour l'apprenant spécifique
            $quizResults = QuizResult::where('user_id', $apprenantId)->get();

            // Calculez la moyenne faible et forte globale
            $globalMinMoyenne = $quizResults->min('moyenne_generale');
            $globalMaxMoyenne = $quizResults->max('moyenne_generale');

            $processedResults = [
                'faible' => $globalMinMoyenne,
                'forte' => $globalMaxMoyenne,
            ];

            return response()->json($processedResults);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //
    public function getQuizScoreResults($apprenantId)
    {
        try {
            // Récupérez les résultats du quiz pour l'apprenant spécifique
            $quizResults = QuizResult::where('user_id', $apprenantId)->get();

            // Regroupez les résultats par niveau
            $groupedResults = $quizResults->groupBy('niveau');

            // Calculez le score faible et fort pour chaque niveau
            $processedResults = [];
            foreach ($groupedResults as $niveau => $results) {
                $minScore = $results->min('total_score');
                $maxScore = $results->max('total_score');

                $processedResults[] = [
                    'niveau' => $niveau,
                    'faible' => $minScore,
                    'fort' => $maxScore,
                ];
            }

             return response()->json($processedResults);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //
    public function getQuizGlobalScoreResults($apprenantId)
    {
        try {
            // Récupérez les résultats du quiz pour l'apprenant spécifique
            $quizResults = QuizResult::where('user_id', $apprenantId)->get();

            // Calculez le score faible et fort global
            $globalMinScore = $quizResults->min('total_score');
            $globalMaxScore = $quizResults->max('total_score');

            $processedResults = [
                'faible' => $globalMinScore,
                'fort' => $globalMaxScore,
            ];

            return response()->json($processedResults);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //Temps passe
    public function getQuizTimeSpentResults($apprenantId)
    {
        try {
            // Récupérez les résultats du quiz pour l'apprenant spécifique
            $quizResults = QuizResult::where('user_id', $apprenantId)->get();

            // Regroupez les résultats par niveau
            $groupedResults = $quizResults->groupBy('niveau');

            // Calculez la somme du temps passé pour chaque niveau
            $processedResults = [];
            foreach ($groupedResults as $niveau => $results) {
                $totalTimeSpent = $results->sum('temps_passe');

                $processedResults[] = [
                    'niveau' => $niveau,
                    'temps_passe' => $totalTimeSpent,
                ];
            }

            return response()->json($processedResults);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    //
    public function getUsersWhoTookQuizToday()
    {
        // Obtenez la date d'aujourd'hui
        $today = Carbon::today();

        // Récupérez la liste distincte des user_id qui ont effectué un quiz aujourd'hui
        $userIds = QuizResult::whereDate('created_at', $today)
            ->distinct()
            ->pluck('user_id');

        // Récupérez les détails de chaque utilisateur
        $users = User::whereIn('id', $userIds)->get();

        // Retournez les détails des utilisateurs
        return response()->json(['users' => $users]);
    }

    //
    public function getLastActivityDetails($id)
    {
        $today = Carbon::today();

        // Récupérez la dernière activité (quiz) de l'utilisateur pour aujourd'hui
        $lastActivity = QuizResult::where('user_id', $id)
        ->whereDate('created_at', $today)
        ->select(
            'niveau', 
            'total_score', 
            'moyenne_generale', 
            'temps_passe',
            'nombre_questions_reussies',
            'nombre_questions_echouees')
        ->latest('created_at')
        ->first();

        return response()->json(['last_activity' => $lastActivity]);
    }

}




