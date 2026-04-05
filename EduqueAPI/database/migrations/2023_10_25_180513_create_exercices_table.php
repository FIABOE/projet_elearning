<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('exercices', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('filiere_id')->default(0);
            $table->string('pdf_file')->nullable(); // Colonne pour stocker le nom du fichier PDF
            $table->string('pdf_file_name')->unique()->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->foreign('user_id')->references('id')->on('users');
            $table->timestamps();

            // Définissez la relation avec la table "filieres"
            $table->foreign('filiere_id')->references('id')->on('filieres')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('exercices', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });
    }
};
