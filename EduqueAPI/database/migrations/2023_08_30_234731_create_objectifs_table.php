<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('objectifs', function (Blueprint $table) {
            $table->id();
            $table->string('libelle');
            $table->timestamps();
        });

        // Ajoutez des enregistrements dans la table d'objectifs
        DB::table('objectifs')->insert([
            //['libelle' => 'Je révise 1h30/semaine'],
            //['libelle' => 'Je révise 1h/semaine'],
            ['libelle' => 'Je révise 30min/semaine'],
            ['libelle' => 'Je révise 15min/semaine'],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('objectifs');
    }
};
