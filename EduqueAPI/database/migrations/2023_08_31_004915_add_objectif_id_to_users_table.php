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
    Schema::table('users', function (Blueprint $table) {
        $table->unsignedBigInteger('objectif_id')->nullable();
        $table->foreign('objectif_id')->references('id')->on('objectifs');
    });
}

public function down()
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropForeign(['objectif_id']);
        $table->dropColumn('objectif_id');
    });
}
};
