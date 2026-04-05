<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    use HasFactory;

    //Sauvegarde des questions
/*public function saveQuestionResult(Request $request)
{

    try{
        $average = $request->input("moyenne_generale");
        $totalScore = $request->input("total_score");
        $niveau = $request->input("niveau");
        $nombre_questions_repondues = $request->input("nombre_questions_repondues");
        $temps_passe = $request->input("temps_passe");
    
    
        $quizResult = QuizResult::create(
            [
                'user_id' => auth()->user()->id, 
                'niveau' => $niveau, 
                'total_score' => $totalScore,
                'nombre_questions_repondues' => $nombre_questions_repondues ,
                'moyenne_generale' => $average,
                'temps_passe' => $temps_passe
            ]
        );
    
    
        return response()->json([
            "message" => "data saved",
            200
        ]);
    }
    catch(\Throwable $th){
        error_log($th);
    }

}


public function getLastAverage(){
    try {
        $userId = auth()->user()->id;
        $result = QuizResult::where('user_id', $userId)->orderByDesc('created_at')->first();
        //$result = QuizResult::where('user_id',$userId)->orderBy('created_at','desc')->get()->take(1);
        return response()->json([
            'result' => $result,
        ]);
    } catch (\Throwable $th) {
        error_log($th);
        return response()->json([
            'message' => 'Erreur lors de la récupération de la moyenne',
            'error' => $th->getMessage(),
        ], 500);
    }
    try {
        //code...
        $userId = auth()->user()->id;
        $result = QuizResult::where('user_id',$userId)->orderBy('created_at','desc')->get()->take(1);
        error_log($result);
        return response()->json([
            "result" => $result
        ]);
    } catch (\Throwable $th) {
        //throw $th;
        error_log($th);
    }


}

public function getObjectif(){
    $user = auth()->user();
    $dateDebutSemaine = Carbon::now()->startOfWeek();
    $results = QuizResult::where('user_id',$user->id)
    ->where('created_at', '>=', $dateDebutSemaine)
    ->get();
    $quota = 0;
    foreach ($results as $result) {
        $quota = $quota + ($result->temps_passe / 60);
    }
    error_log($quota);
    return response()->json([
        "duree" => $user->objectif->duree,
        "quota" => $quota
    ],200);
}

/*public function getTotalScoreForUser($userId)
{
    $user = User::find($userId);

    if (!$user) {
        return response()->json(['error' => 'User not found'], 404);
    }

    // Récupérez les statistiques pour l'utilisateur, groupées par niveau
    $statsByNiveau = QuizResult::where('user_id', $userId)
        ->groupBy('niveau_id')
        ->selectRaw('niveau_id, sum(total_score) as total_score, sum(nombre_questions_repondues) as nombre_questions_repondues, avg(moyenne_generale) as moyenne_generale')
        ->get();

    return response()->json(['stats_by_niveau' => $statsByNiveau], 200);
}*/

 /*function getNumbersFromString($str) {
        $matches = array();
        preg_match_all('/([0-9]+)/', $str, $matches);
        return $matches;
    }

    if (preg_match($pattern, $chaine, $matches)) {
        // $matches[0] contient le premier nombre trouvé dans la chaîne
        $nombre = $matches[0];
    }*/



     //$questions = Quiz::orderBy('id', 'asc')->get();
    /*$userAnswer = $request->input('selected_option');
    $questionId = $request->input('question_id');
    $userId = auth()->user()->id;



    // Récupérez la question à partir de la table quizzes
    $question = Quiz::find($questionId);

    // Assurez-vous que la question est trouvée
    if ($question) {
        $correctAnswer = $question->correct_option;
        log::info('Selected Option: ' . $userAnswer);
        log::info('Correct Answer: ' . $correctAnswer);
        // Reste du code inchangé
        $isCorrect = $userAnswer == $correctAnswer;
        log::info('Is Correct (on server): ' . ($isCorrect ? 'true' : 'false'));
        // Enregistrez le temps passé sur la question
        $tempsPasse = $request->input('temps_passe');

        // Recherchez s'il y a déjà un enregistrement pour cette question et cet utilisateur
        $existingResult = QuestionResult::where('user_id', $userId)
            ->where('question_id', $questionId)
            ->first();

        if ($existingResult) {
            // Si un enregistrement existe, mettez à jour les détails
            $existingResult->update([
                'selected_option' => $userAnswer,
                'is_correct' => $isCorrect,
                'score' => $isCorrect ? $question->score : 0,
                'temps_passe' => $tempsPasse,
            ]);
        } else {
            // Sinon, créez un nouvel enregistrement
            QuestionResult::create([
                'user_id' => $userId,
                'question_id' => $questionId,
                'niveau' => $question->niveau, // Assurez-vous d'avoir ce champ dans ta table quizzes
                'selected_option' => $userAnswer,
                'is_correct' => $isCorrect,
                'score' => $isCorrect ? $question->score : 0,
                'temps_passe' => $tempsPasse,
            ]);
        }
    
        // Mettez à jour le score total de l'utilisateur dans la table quiz_results
        $userTotalScore = QuestionResult::where('user_id', $userId)
            ->where('niveau', $question->niveau)
            ->sum('score');
        $userTotalQuestions = QuestionResult::where('user_id', $userId)
            ->where('niveau', $question->niveau)
            ->count();

        // Recherchez ou créez une entrée dans la table quiz_results
        $quizResult = QuizResult::firstOrNew(['user_id' => $userId, 'niveau' => $question->niveau]);
        $quizResult->total_score = $userTotalScore;
        $quizResult->nombre_questions_repondues = $userTotalQuestions;
        $quizResult->moyenne_generale = $userTotalQuestions > 0 ? $userTotalScore / $userTotalQuestions : 0; // Évitez la division par zéro
        $quizResult->temps_passe = $quizResult->temps_passe + $tempsPasse; // Enregistrez le temps passé total dans quiz_results
        $quizResult->save();

        // Log après le traitement pour éviter de bloquer l'exécution du code
        log::info('Question result saved successfully.');

        return response()->json(['is_correct' => $isCorrect], 200);
    } else {
        // Gérer le cas où la question n'est pas trouvée
        log::info('Question ID does not match the question in the database.');
        return response()->json(['error' => 'Question ID does not match the question in the database.'], 400);
    }*/


}
