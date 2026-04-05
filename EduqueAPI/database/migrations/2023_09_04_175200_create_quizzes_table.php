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
    Schema::create('quizzes', function (Blueprint $table) {
        $table->id();
        $table->unsignedBigInteger('filiere_id');
        $table->text('question');
        $table->text('options');
        $table->string('correct_option');
        $table->enum('type_quiz', ['qcm', 'vrai_ou_faux']); // Types de quiz possibles
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quizzes');
    }
};
