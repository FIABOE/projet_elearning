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
            $table->integer('temps_passe')->default(0)->after('total_score');
        });
    }

    public function down()
    {
        Schema::table('quiz_results', function (Blueprint $table) {
            $table->dropColumn('temps_passe');
        });
    }

};
