<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\ForgetPasswordController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\NewPasswordController;
use App\Http\Controllers\API\ResetPasswordController;
use App\Http\Controllers\FiliereController;
use App\Http\Controllers\CoursController;
use App\Http\Controllers\FavoriController;
use App\Http\Controllers\ExercicesController;
use App\Http\Controllers\ModeratorController;
use App\Http\Controllers\ApprenantControlleur;
use App\Http\Controllers\ProfilController;
use App\Http\Controllers\QuizController;
use App\Http\Controllers\RatingController;
use App\Http\Controllers\ObjectifController;
use App\Http\Controllers\TotalsController;
use App\Http\Middleware\CheckIsActive;
use App\Http\Requests\Auth\ForgetPasswordRequest;
use App\Models\Objectif;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

// Routes publiques (non authentifiées)
Route::controller(AuthController::class)->group(function () {
    Route::post('login', 'login')->name('login');
    Route::post('register', 'register')->name('register');
    Route::post('forgot-password', 'forgotPassword');
    Route::post('reset-password', 'reset');
});

Route::controller(NewPasswordController::class)->group(function () {
    Route::post('forgot-password', 'forgotPassword');
    Route::post('reset-password', 'reset');
});


Route::post('/register-moderateur', [ModeratorController::class, 'register']);
Route::get('/moderators', [ModeratorController::class, 'getAllModerators']);
Route::get('/apprenants', [ApprenantControlleur::class, 'getAllApprenants']);
Route::middleware('auth:sanctum')->get('/user/profile', [ProfilController::class, 'getUserProfile']);

Route::put('/moderateurs/{id}/deactivate', [ModeratorController::class, 'deactivateMod']);
Route::put('/moderateurs/{id}/activate', [ModeratorController::class, 'activateMod']);

Route::put('/apprenants/{id}/deactivate', [ApprenantControlleur::class, 'deactivateMod']);
Route::put('/apprenants/{id}/activate', [ApprenantControlleur::class, 'activateMod']);


Route::get('/get-totals', [TotalsController::class, 'getTotals']);
Route::get('/get-Niv_Moyenne/apprenants/{id}', [TotalsController::class, 'getQuizResults']);
Route::get('/get-global_Moyenne/apprenants/{id}', [TotalsController::class, 'getQuizglobalResults']);

Route::get('/get-Niv_Score/apprenants/{id}', [TotalsController::class, 'getQuizScoreResults']);
Route::get('/get-global_Score/apprenants/{id}', [TotalsController::class, 'getQuizglobalScoreResults']);
Route::get('/quiz/time-spent/apprenants/{Id}', [TotalsController::class, 'getQuizTimeSpentResults']);
Route::delete('/users/{user}', [AuthController::class, 'destroy']);

Route::get('/user-registration-stats', [UserController::class, 'getUserCountByDay']);
Route::get('/user-registration-week', [UserController::class, 'getUserCountByWeek']);
Route::get('/user-registration-month', [UserController::class, 'getUserCountByMonth']);

Route::get('/quiz-stats', [UserController::class, 'getQuizCountByDay']);
Route::get('/quiz-week', [UserController::class, 'getQuizCountByWeek']);
Route::get('/quiz-month', [UserController::class, 'getQuizCountByMonth']);

Route::get('/cours-stats', [UserController::class, 'getCoursCountByDay']);
Route::get('/cours-week', [UserController::class, 'getCoursCountByWeek']);
Route::get('/cours-month', [UserController::class, 'getCoursCountByMonth']);

Route::get('/filiere-stats', [UserController::class, 'getFilieresCountByDay']);
Route::get('/filiere-week', [UserController::class, 'getFilieresCountByWeek']);
Route::get('/filiere-month', [UserController::class, 'getFilieresCountByMonth']);

Route::get('/objectif-stats', [UserController::class, 'getObjectifCountByDay']);
Route::get('/objectif-week', [UserController::class, 'getObjectifCountByWeek']);
Route::get('/objectif-month', [UserController::class, 'getObjectifCountByMonth']);

Route::get('/exercice-stats', [UserController::class, 'getExercicesCountByDay']);
Route::get('/exercice-week', [UserController::class, 'getExercicesCountByWeek']);
Route::get('/exercice-month', [UserController::class, 'getExercicesCountByMonth']);


// Routes nécessitant l'authentification (utilisateur normal)
Route::middleware('auth:sanctum')->group(function () {
     Route::get('/user', function () {
        $user = auth()->user()->load('filiere', 'objectif');
        
        return response()->json([
            'user' => $user->toArray()
        ]);
    });
    Route::middleware(['checkIsActive'])->group(function () {
        Route::resource('filieres', FiliereController::class);
        //Route::post('/choisir-filiere', 'API\UserController@choisirFiliere');
        Route::post('/choisir-filiere', [UserController::class, 'choisirFiliere']);
        Route::post('/choisir-objectif', [UserController::class, 'choisirObjectif']);
        Route::get('/niveaux', [QuizController::class, 'getNiveaux']);
        Route::post('/objectif', [UserController::class, 'saveObjectif']);
        Route::post('/filiere', [UserController::class, 'savefiliere']);
        Route::post('/revokeTokens', [AuthController::class, 'revokeTokens']);
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::delete('/delete', [AuthController::class, 'deleteAccount']);
        Route::put('/update', [AuthController::class, 'updateUser']);
        //Route::resource('filieres', FiliereController::class);
        Route::resource('objectifs', ObjectifController::class);
        Route::resource('cours', CoursController::class);
        Route::resource('exercices',ExercicesController::class);
        Route::resource('quizzes', QuizController::class);
        Route::get('/quiz/{filiere_id}', [QuizController::class, 'getQuizByFiliere']);
        Route::get('/list_cours/{filiere_id}', [CoursController::class, 'getCoursByFiliere']);
        Route::get('/list_exercices/{filiere_id}', [ExercicesController::class, 'getexercicesByFiliere']);
        Route::get('/quiz/{filiere_id}/{niveau}', [QuizController::class, 'getQuizByFiliereAndNiveau']);
        Route::post('/get-quizzes', [QuizController::class, 'getQuizzesByFiliereAndNiveau']);
        Route::resource('/profil', ProfilController::class);
        // Exemple de route pour récupérer le niveau choisi par l'utilisateur
        Route::get('/niveau', [QuizController::class, 'getNiveau']);
        //Route::get('/pdf/{pdfFileName}', [CoursController::class, 'showPdf']);
        //Route::put('/profile', [ProfilController::class, 'update']);
        Route::post('/update-user-and-profile', [AuthController::class, 'updateUserAndProfile']);
        Route::get('moderateurs/{moderateurId}/filieres', [FiliereController::class, 'getFilieresByModerateur']);
        Route::get('moderateurs/{moderateurId}/objectifs', [ObjectifController::class, 'getObjectifsByModerateur']);
        Route::get('moderateurs/{moderateurId}/quizzes', [QuizController::class, 'getQuizzesByModerator']);
        Route::get('/moderateurs/{moderateurId}/cours', [CoursController::class, 'getCoursByModerator']);
        Route::get('/moderateurs/{moderateurId}/exercices', [ExercicesController::class, 'getexercicesByModerator']);

        // Ajoutez une route pour mettre à jour un modérateur par son ID
        Route::put('/moderateurs/{id}', [ModeratorController::class, 'update']);
        Route::get('/api/filieres', [FiliereController::class, 'getFiliereIdByLibelle']);
        Route::post('favoris/add', [FavoriController::class, 'addFavori']);

        // Supprimer un favori
        Route::post('favoris/remove', [FavoriController::class, 'removeFavori']);
        Route::delete('favoris/remove', [FavoriController::class, 'removeFavori']);
        Route::get('/get_favorite_cours',  [FavoriController::class, 'getFavoriteCours']);
        Route::post('/submit-rating', [RatingController::class,'submitRating']);
        Route::get('/users/{id}/rating', [RatingController::class,'getUserRating']);
        Route::get('/users-with-rating', [RatingController::class,'getUsersWithRating']);
        Route::post('/save-question-result', [QuizController::class, 'saveQuestionResult']);
        Route::get('/last-question-result', [QuizController::class, 'getLastAverage']);
        Route::get('/quota', [QuizController::class, 'getObjectif']);
        Route::get('/quiz-results/total-score/{userId}', [QuizController::class, 'getTotalScoreForUser']);
        Route::get('/user/{id}', [UserController::class, 'UserControllershow']);
        Route::get('/favoris/user/{user_id}', [FavoriController::class, 'getFavorisByUser']);
        Route::get('/users-who-took-quiz-today', [TotalsController::class, 'getUsersWhoTookQuizToday']);
        Route::get('/last-activity-details/apprenants/{Id}', [TotalsController::class, 'getLastActivityDetails']);
        
        Route::post('email-verification',[EmailverificationController::class, 'email_verfication']);
        Route::get('email-verification',[EmailverificationController::class, 'email_verfication']);

        Route::post('password/forgot-password', [ForgetPasswordController::class, 'forgotPassword']);
        Route::post('password/resend-otp', [ForgetPasswordController::class, 'resendOtp']);
        Route::post('password/verify-otp', [ForgetPasswordController::class, 'verifyOtp']);
        Route::post('password/reset', [ResetPasswordController::class, 'passwordReset']);
        Route::post('password/reset2', [ResetPasswordController::class, 'passwordReset2']);

   
   
    });
});
 