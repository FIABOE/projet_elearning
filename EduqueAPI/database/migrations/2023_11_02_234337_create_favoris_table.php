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
        Schema::create('favoris', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('cours_id');
            $table->timestamps();

            // Définissez les clés étrangères
            $table->foreign('user_id')->references('id')->on('users');
            $table->foreign('cours_id')->references('id')->on('cours');
        });
    }

    public function down()
    {
        Schema::dropIfExists('favoris');
    }
};
