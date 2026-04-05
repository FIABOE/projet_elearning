<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->integer('score')->default(0); // Ajoutez le champ "score" (de type integer) avec une valeur par défaut de 0
        });
    }

    public function down()
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropColumn('score'); // Supprimez le champ "score" si nécessaire lors d'une migration inverse
        });
    }
};

