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
            $table->integer('note_app')->default(0); // Ajoutez la colonne "note_app" avec une valeur par défaut de 0
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('note_app'); // Supprimez la colonne "note_app" en cas de rollback de la migration
        });
    }
};
