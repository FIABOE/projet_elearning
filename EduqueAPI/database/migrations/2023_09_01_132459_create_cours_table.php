<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCoursTable extends Migration
{
    public function up()
    {
        Schema::create('cours', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('filiere_id')->default(0);
            $table->string('pdf_file')->nullable(); // Colonne pour stocker le nom du fichier PDF
            $table->timestamps();

            // Définissez la relation avec la table "filieres"
            $table->foreign('filiere_id')->references('id')->on('filieres')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('cours');
    }
}
