<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Models\User;
use App\Models\Cours;
use Illuminate\Support\Facades\Storage;
use App\Models\Profil;
use App\Models\UserLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;
use App\Notifications\LoginNotification;
use App\Notifications\EmailVerificationNotification;
 

class AuthController extends Controller
{

    //GESTION D'INSCRIPTION

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'surname' => 'required|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'dateNais' => 'required|date_format:Y-m-d|before:-15 years',
            'email' => 'required|email|max:255|unique:users',
            'password' => 'required|min:8',
            'c_password' => 'required|same:password',
            'consent' => 'required|in:true,false',
        ], [
            'dateNais.before' => 'Vous devez avoir au moins 15 ans pour vous inscrire.',
            'name.regex' => 'Le nom ne doit pas contenir de caractères spéciaux.',
            'surname.regex' => 'Le prénom ne doit pas contenir de caractères spéciaux.',
            'email.email' => 'Veuillez entrer une adresse e-mail valide.',
            'email.unique' => 'Cette adresse e-mail est déjà utilisée.',
            'consent.required' => 'Veuillez accepter les conditions générales d\'utilisation pour vous inscrire.',
        ]);

        if ($validator->fails()) {
            $response = [
                'success' => false,
                'message' => $validator->errors(),
            ];
            return response()->json($response, 400);
        }
        $consent = $request->input('consent');

        //var_dump($consent);
        if ($consent === 'false') {
            $response = [
                'success' => false,
                'message' => 'Vous devez accepter les conditions générales d\'utilisation pour vous inscrire.',
            ];
            return response()->json($response, 400);
        }
        
        $consent = filter_var($request->input('consent'), FILTER_VALIDATE_BOOLEAN);
        $input = $request->all();
        $input['password'] = bcrypt($input['password']);
        $input['consent'] = $consent;
        
        $user = User::create($input);
        
        $token = $user->createToken('Myapp')->plainTextToken; // Génération du jeton d'accès
        $user->update(['remember_token' => $token]); // Associer le jeton à l'utilisateur dans la base de données
       
        $success['token'] = $token;
        $success['name'] = $user->name;
        $success['surname'] = $user->surname;
        $success['dateNais'] = $user->dateNais;
        $success['consent'] = $user->consent;
        $success['role'] = $user->role;
       // $user->notify(new EmailVerificationNotification());
        $response = [
            'success' => true,
            'data' => $success,
            'message' => 'User registered successfully',
        ];
        return response()->json($response, 200);
    }
     

    public function login(Request $request)
    {
        try{
            if (Auth::attempt([
                'email' => $request->email,
                'password' => $request->password,
            ])) {
                $user = Auth::user();

                if ($user->is_active == 1) {
                    $success['token'] = $user->createToken('Myapp')->plainTextToken;
                    $success['name'] = $user->name;
                    $success['surname'] = $user->surname;
                    $success['dateNais'] = $user->dateNais;
                    $success['role'] = $user->role;

                    //$user->notify(new LoginNotification());

                    // Récupérer le rôle de l'utilisateur
                    $role = $user->role;

                    if ($role === 'admin') {
                        $response = [
                            'success' => true,
                            'data' => $success,
                            'message' => 'Admin logged in successfully',
                        ];
                    } elseif ($role === 'moderateur') {
                        $response = [
                            'success' => true,
                            'data' => $success,
                            'message' => 'Moderator logged in successfully',
                        ];
                    } else {
                        $response = [
                            'success' => true,
                            'data' => $success,
                            'message' => 'User logged in successfully',
                        ];
                    }
                    return response()->json($response, 200);
                } else {
                    // Compte inactif
                    $response = [
                        'success' => false,
                        'message' => 'Account is inactive',
                    ];
                    return response()->json($response, 403);
                }
            } else {
                // Identifiants incorrects
                $response = [
                    'success' => false,
                    'message' => 'Invalid credentials',
                ];
                return response()->json($response, 401);
            }
        }
        catch(Exception $e){
            error_log($e->getMessage());
        }
    }



    // GESTION DE DECONNEXION
    public function logout(Request $request)
    {
        $user = $request->user();
        // Récupérer le rôle de l'utilisateur
        $role = $user->role; 
        
        if ($role === 'admin') {
            return response()->json([
                'success' => true,
                'message' => 'Admin logged out successfully'
            ]);
        } else {
            return response()->json([
                'success' => true,
                'message' => 'User logged out successfully'
            ]);
        }
    }
    
    // GESTION DE REVOCATION DE JETONS
    public function revokeTokens(Request $request)
    {
        $user = $request->user();
        $user->tokens->each->delete();
        
        $role = $user->role; 
        
        if ($role === 'admin') {
            return response()->json([
                'success' => true,
                'message' => 'All tokens revoked for admin'
            ]);
        } else {
            return response()->json([
                'success' => true,
                'message' => 'All tokens revoked for user'
            ]);
        }
    }
    
    // GESTION DE SUPPRESSION DE COMPTE
    public function deleteAccount(Request $request)
    {
        $user = $request->user();// Obtenez l'instance de l'utilisateur à partir de la requête 
        
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }
        
        $user->delete(); //Supprimez l'utilisateur
        return response()->json([
            'success' => true,
            'message' => 'User account deleted successfully',
        ]);
    }
    
    public function updateUser(Request $request)
    {
        // Vérifiez si l'utilisateur est connecté
        if (Auth::check()) {
            // Récupérer l'utilisateur connecté
            $user = Auth::user();
    
            // Valider les données
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
                'surname' => 'required|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
                'dateNais' => 'required|date_format:Y-m-d|before:-15 years',
                'email' => [
                    'required',
                    'email',
                    'max:255',
                    Rule::unique('users', 'email')->ignore($user->id),
                ],
            ]);
    
            // Vérifiez si la validation a échoué
            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 400);
            }
    
            // Obtenez les données validées
            $validatedData = $validator->validated();
    
            // Mettre à jour les attributs de l'utilisateur avec les nouvelles données
            if ($user->update($validatedData)) {
                return response()->json([
                    'success' => true,
                    'message' => 'User information updated successfully',
                    'data' => $user
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to update user information',
                ], 500);
            }
        } else {
            // L'utilisateur n'est pas connecté, gérer l'erreur ici
            return response()->json([
                'success' => false,
                'message' => 'User not authenticated',
            ], 401);
        }
    }

    public function updateUserAndProfile(Request $request)
    {
        // Récupérez l'utilisateur connecté
        $user = auth()->user();
    
        // Validez les données de la demande pour la mise à jour de l'utilisateur
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'surname' => 'sometimes|string|max:255|min:2|regex:/^[a-zA-Z\s]+$/',
            'dateNais' => 'sometimes|date_format:Y-m-d|before:-15 years',
            'email' => 'sometimes|email|max:255',
            // Ajoutez d'autres règles de validation au besoin
        ]);
    
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
    
        // Récupérez les données de mise à jour pour l'utilisateur
        $userData = array_filter($request->only(['name', 'surname', 'dateNais', 'email']));
    
        // Parcourez les données et conservez les anciennes valeurs si les nouveaux champs sont vides
        foreach ($userData as $key => $value) {
            if (empty($value)) {
                $userData[$key] = $user->$key; // Utilisez l'ancienne valeur
            }
        }
        // Mettez à jour les attributs de l'utilisateur avec les nouvelles données
        $user->update($userData);
    
        // Validez les données de la demande pour la mise à jour du profil
        $validator = Validator::make($request->all(), [
            'pseudo' => 'sometimes|string|max:255',
            // Ajoutez d'autres règles de validation au besoin
        ]);
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
        // Récupérez le profil de l'utilisateur (ou créez-en un s'il n'en a pas)
        $profil = $user->profil ?: new Profil();
        // Mettez à jour le pseudo du profil
        $pseudo = $request->input('pseudo');
        if (!empty($pseudo)) {
            $profil->pseudo = $pseudo;
        }
        // Gérez le téléchargement de l'avatar
        if ($request->hasFile('avatar')) {
            $avatar = $request->file('avatar');
            $avatarPath = $avatar->store('avatars', 'public');
            $profil->avatar = $avatarPath;
        }
        // Sauvegardez les modifications du profil
        $profil->save();
        return response()->json([
            'message' => 'Informations de l\'utilisateur et du profil mises à jour avec succès.',
            'user' => $user,
            'profil' => $profil,
        ], 200);
    }
    //Suppression de compte 
    // app/Http/Controllers/UserController.php
    public function destroy($id)
    {
        // Recherchez le cours par ID
        $cours = Cours::find($id);
        if (!$cours) {
            return response()->json(['error' => 'Cours non trouvé'], 404);
        }
        // Supprimez le fichier PDF associé, s'il existe
        if (Storage::disk('public')->exists($cours->pdf_file)) {
            Storage::disk('public')->delete($cours->pdf_file);
        }
        // Supprimez les favoris associés à ce cours
        $cours->favoris()->delete();
        // Supprimez le cours de la base de données
        $cours->delete();
        return response()->json(['message' => 'Cours supprimé avec succès'], 200);
    }
}

