<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProfilsTable extends Migration
{
    public function up()
    {
        Schema::create('profils', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id'); // Clé étrangère vers la table "users"
            $table->string('avatar')->nullable();
            $table->string('pseudo')->nullable();
            $table->timestamps();
        });

        

        Schema::table('profils', function (Blueprint $table) {
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('profils');
    }
}
