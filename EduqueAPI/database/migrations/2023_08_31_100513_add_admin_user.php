<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Models\User;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        // Ajouter un utilisateur administrateur
        $admin = new User([
            'name' => 'Admin',
            'surname' => 'Admin',
            'dateNais' => now(),
            'email' => 'admin@example.com',
            'password' => bcrypt('adminpassword'), 
            'role' => 'admin', 
        ]);
        $admin->save();

        // Générer un token d'authentification pour l'administrateur et le stocker dans la base de données
        $token = $admin->createToken('admin-token')->plainTextToken;
        $admin->remember_token = $token;
        $admin->save();
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        // Supprimer l'administrateur si nécessaire
        $admin = User::where('email', 'admin@example.com')->first();
        if ($admin) {
            $admin->delete();
        }
    }
};
