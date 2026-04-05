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
    Schema::table('quiz_results', function (Blueprint $table) {
        $table->integer('nombre_questions_repondues')->default(0);
        $table->decimal('moyenne_generale', 5, 2)->default(0.00);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('quiz_results', function (Blueprint $table) {
            //
        });
    }
};
