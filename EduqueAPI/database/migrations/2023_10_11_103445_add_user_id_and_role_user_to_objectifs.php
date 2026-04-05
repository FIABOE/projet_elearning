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
        Schema::table('objectifs', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id'); // Ajoutez la colonne user_id
            $table->string('role_user')->nullable();
        });
    }


       
    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('objectifs', function (Blueprint $table) {
            //
        });
    }
};
