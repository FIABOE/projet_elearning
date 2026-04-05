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
            $table->unsignedBigInteger('user_id'); // Ajoutez la colonne user_id
            $table->string('role_user')->nullable();
        });
    }

    public function down()
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropColumn('user_id'); // Supprimez la colonne user_id
            $table->dropColumn('role_user'); // Supprimez la colonne role_user
        });
    }
};
