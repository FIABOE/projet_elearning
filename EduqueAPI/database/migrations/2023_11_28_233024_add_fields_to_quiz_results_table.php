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
        $table->integer('nombre_questions_reussies')->after('nombre_questions_repondues');
        $table->integer('nombre_questions_echouees')->after('nombre_questions_reussies');
    });
}

public function down()
{
    Schema::table('quiz_results', function (Blueprint $table) {
        $table->dropColumn(['nombre_questions_reussies', 'nombre_questions_echouees']);
    });
}

};
