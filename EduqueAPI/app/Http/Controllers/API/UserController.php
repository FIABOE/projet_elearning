<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use App\Models\Objectif;
use App\Models\filiere;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
//use Illuminate\Support\Facades\DB;

class UserController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth:sanctum'); // Appliquer l'authentification à toutes les méthodes du contrôleur
    }
    
    //public function saveObjectif(Request $request)
//{
    //$user = Auth::user();
    //$selectedOption = $request->input('selected_objectif'); 
    //$objectif = Objectif::where('libelle', $selectedOption)->first();
    
    //if ($objectif) {
        // Associez l'objectif à l'utilisateur
        //$user->objectif_id = $objectif->id;
        //$user->save();
        //return response()->json(['message' => 'Objectif saved successfully']);
    //} else {
        //return response()->json(['error' => 'Objectif not found'], 404);
    //}
//}

public function choisirObjectif(Request $request)
{
    // Assurez-vous que l'utilisateur est authentifié
    if (Auth::check()) {
        // Récupérez l'utilisateur actuellement authentifié
        $user = Auth::user();
        
        // Récupérez la filière choisie à partir de la demande
        $selectedObjectif= $request->input('selected_objectif');
        
        // Recherchez la filière dans la base de données
        $objectif = Objectif::where('libelle', $selectedObjectif)->first();

        if ($objectif ) {
            // Associez l'ID de la filière à l'utilisateur
            $user->objectif_id = $objectif ->id;
            $user->save();

            // Retournez la réponse JSON avec le libellé de la filière
            return response()->json([
                'success' => true,
                'message' => 'objectif enregistrée avec succès',
                'filiere' => $objectif->libelle, // Ajoutez le libellé de la filière ici
            ], 200);
        } 
    } else {
        return response()->json([
            'success' => false,
            'error' => 'L\'utilisateur n\'est pas authentifié',
        ], 401);
    }
}

public function choisirFiliere(Request $request)
{
    // Assurez-vous que l'utilisateur est authentifié
    if (Auth::check()) {
        // Récupérez l'utilisateur actuellement authentifié
        $user = Auth::user();
        
        // Récupérez la filière choisie à partir de la demande
        $selectedFiliere = $request->input('selected_filiere');
        
        // Recherchez la filière dans la base de données
        $filiere = Filiere::where('libelle', $selectedFiliere)->first();

        if ($filiere) {
            // Associez l'ID de la filière à l'utilisateur
            $user->filiere_id = $filiere->id;
            $user->save();

            // Retournez la réponse JSON avec le libellé de la filière
            return response()->json([
                'success' => true,
                'message' => 'Filière enregistrée avec succès',
                'filiere' => $filiere->libelle, // Ajoutez le libellé de la filière ici
            ], 200);
        } 
    } else {
        return response()->json([
            'success' => false,
            'error' => 'L\'utilisateur n\'est pas authentifié',
        ], 401);
    }
}
//public function savefiliere(Request $request)
//{
    //$this->middleware('auth:sanctum');
    // Assurez-vous que l'utilisateur est authentifié
    //if (Auth::check()) {
        //$user = Auth::user();
        //$selectedOption = $request->input('selected_filiere'); 

        //$filiere = filiere::where('libelle', $selectedOption)->first();

        ///if ($filiere) {
         //Associez l'ID de la filière à l'utilisateur
            //$user->filiere_id = $filiere->id;
            //$user->save();

            //return response()->json(['filiere_id' => $filiere->id]);
        //} else {
            //return response()->json(['error' => 'filiere not found'], 404);
        //}
    //} else {
        //return response()->json(['error' => 'User not authenticated'], 401);
    //}
//}

    //
    public function UserControllershow($id)
    {
        // Récupérez les informations de l'utilisateur par ID
        $user = User::find($id);

        if (!$user) {
            return response()->json(['error' => 'Utilisateur non trouvé'], 404);
        }

        return response()->json(['user' => $user]);
    }

    

    //Affichage du nombre d'apprenant par jour
    public function getUserCountByDay() {
        return DB::table('users')
            ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as user_count'))
            ->groupBy('day')
            ->get();
    }
    public function getUserStats() {
        $userCountByDay = $this->getUserCountByDay();

        return response()->json([
            'userCountByDay' => $userCountByDay,
        ]);
    }

    //Affichage du nombre d'apprenant par semaine 
    public function getUserCountByWeek() {
        return DB::table('users')
            ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
            ->groupBy('week')
            ->get();
    }

    public function getUserweekStats() {
        $userCountByWeek = $this->getUserCountByWeek();

        return response()->json([
            'userCountByWeek' => $userCountByWeek,
        ]);
    }
    
    //Affichage du nombre d'apprenant par semaine
    public function getUserCountByMonth() {
        return DB::table('users')
            ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
            ->groupBy('month')
            ->get();
    }
    public function getUserMonthStats() {
        $userCountByMonth = $this->getUserCountByMonth();

        return response()->json([
            '$userCountByMonth' => $userCountByMonth,
        ]);
    }
///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

     //Affichage du nombre de quiz(question) ajouté par jour
     public function getQuizCountByDay()
    {
        return DB::table('quizzes')
            ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as quiz_count'))
            ->groupBy('day')
            ->get();
    }

    public function getQuizStats()
    {
        $quizCountByDay = $this->getQuizCountByDay();

        return response()->json([
            'quizCountByDay' => $quizCountByDay,
        ]);
    }

    //Affichage du nombre de quiz(question) ajouté par semaine
    public function getQuizCountByWeek() {
        return DB::table('quizzes')
            ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
            ->groupBy('week')
            ->get();
    }

    public function getQuizweekStats() {
        $quizCountByWeek = $this->getQuizCountByWeek();

        return response()->json([
            'quizCountByWeek' => $quizCountByWeek,
        ]);
    }
    
   //Affichage du nombre de quiz(question) ajouté par mois
    public function getQuizCountByMonth() {
        return DB::table('quizzes')
            ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
            ->groupBy('month')
            ->get();
    }
    public function getQuizMonthStats() {
        $quizCountByMonth = $this->getQuizCountByMonth();

        return response()->json([
            '$quizCountByMonth' => $quizCountByMonth,
        ]);
    }

///////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

     //Affichage du nombre de Objectif ajouté par jour
     public function getObjectifCountByDay()
    {
        return DB::table('objectifs')
            ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as objectif_count'))
            ->groupBy('day')
            ->get();
    }

    public function getObjectifStats()
    {
        $objectifCountByDay = $this->getObjectifCountByDay();

        return response()->json([
            'objectifCountByDay' => $objectifCountByDay,
        ]);
    }

    //Affichage du nombre de objectifs ajouté par semaine
    public function getObjectifCountByWeek() {
        return DB::table('objectifs')
            ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
            ->groupBy('week')
            ->get();
    }

    public function getObjectifweekStats() {
        $objectifCountByWeek = $this->getObjectifCountByWeek();

        return response()->json([
            'objectifCountByWeek' => $objectifCountByWeek,
        ]);
    }
    
   //Affichage du nombre de OBJECTIFS ajouté par mois
    public function getObjectifCountByMonth() {
        return DB::table('objectifs')
            ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
            ->groupBy('month')
            ->get();
    }
    public function getObjectifMonthStats() {
        $objectifCountByMonth = $this->getObjectifCountByMonth();

        return response()->json([
            '$objectifCountByMonth' => $objectifCountByMonth,
        ]);
    }
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//Affichage du nombre de cours ajouté par jour
public function getCoursCountByDay()
{
    return DB::table('cours')
        ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as cour_count'))
        ->groupBy('day')
        ->get();
}

public function getCoursStats()
{
    $courCountByDay = $this->getCoursCountByDay();

    return response()->json([
        'courCountByDay' => $courCountByDay,
    ]);
}

//Affichage du nombre de cours ajouté par semaine
public function getCoursCountByWeek() {
    return DB::table('cours')
        ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
        ->groupBy('week')
        ->get();
}

public function getCoursweekStats() {
    $courCountByWeek = $this->getCoursCountByWeek();

    return response()->json([
        'courCountByWeek' => $courCountByWeek,
    ]);
}

//Affichage du nombre de cours ajouté par mois
public function getCoursCountByMonth() {
    return DB::table('cours')
        ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
        ->groupBy('month')
        ->get();
}
public function getCoursMonthStats() {
    $courCountByMonth = $this->getCoursCountByMonth();

    return response()->json([
        '$courCountByMonth' => $courCountByMonth,
    ]);
}
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//Affichage du nombre de exercices ajouté par jour
public function getFilieresCountByDay()
{
    return DB::table('filieres')
        ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as filiere_count'))
        ->groupBy('day')
        ->get();
}

public function getFilieresStats()
{
    $filiereCountByDay = $this->getFilieresCountByDay();

    return response()->json([
        'filiereCountByDay' => $filiereCountByDay,
    ]);
}

//Affichage du nombre de exercices ajouté par semaine
public function getFilieresCountByWeek() {
    return DB::table('filieres')
        ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
        ->groupBy('week')
        ->get();
}

public function getFilieresweekStats() {
    $filiereCountByWeek = $this->getFilieresCountByWeek();

    return response()->json([
        'filiereCountByWeek' => $filiereCountByWeek,
    ]);
}

//Affichage du nombre de exercices ajouté par mois
public function getFilieresCountByMonth() {
    return DB::table('filieres')
        ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
        ->groupBy('month')
        ->get();
}
public function getFilieresMonthStats() {
    $filiereCountByMonth = $this->getFilieresCountByMonth();

    return response()->json([
        '$filiereCountByMonth' => $filiereCountByMonth,
    ]);
}
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//Affichage du nombre de exercices ajouté par jour
public function getExercicesCountByDay()
{
    return DB::table('exercices')
        ->select(DB::raw('DATE(created_at) as day'), DB::raw('COUNT(*) as exercice_count'))
        ->groupBy('day')
        ->get();
}

public function getExercicesStats()
{
    $exerciceCountByDay = $this->getFilieresCountByDay();

    return response()->json([
        'exerciceCountByDay' => $exerciceCountByDay,
    ]);
}

//Affichage du nombre de exercices ajouté par semaine
public function getExercicesCountByWeek() {
    return DB::table('exercices')
        ->select(DB::raw('WEEK(created_at) as week'), DB::raw('COUNT(*) as count'))
        ->groupBy('week')
        ->get();
}

public function getExercicessweekStats() {
    $exerciceCountByWeek = $this->getExercicesCountByWeek();

    return response()->json([
        'exerciceCountByWeek' => $exerciceCountByWeek,
    ]);
}

//Affichage du nombre de exercices ajouté par mois
public function getExercicesCountByMonth() {
    return DB::table('exercices')
        ->select(DB::raw('MONTH(created_at) as month'), DB::raw('COUNT(*) as count'))
        ->groupBy('month')
        ->get();
}
public function getExercicesMonthStats() {
    $exerciceCountByMonth = $this->getExercicesCountByMonth();

    return response()->json([
        '$exerciceCountByMonth' => $exerciceCountByMonth,
    ]);
}











    /*public function getUserCountByMonth() {
        return DB::table('users')
            ->select(DB::raw("MONTHNAME(created_at) as month"), DB::raw('COUNT(*) as count'))
            ->groupBy('month')
            ->get();
    }

    public function getUserMonthStats() {
        $userCountByMonth = $this->getUserCountByMonth();

        return response()->json([
            'userCountByMonth' => $userCountByMonth,
        ]);
    }*/

}
