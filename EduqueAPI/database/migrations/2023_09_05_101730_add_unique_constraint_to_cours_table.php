<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddUniqueConstraintToCoursTable extends Migration
{
    public function up()
    {
        Schema::table('cours', function (Blueprint $table) {
            $table->unique('pdf_file');
        });
    }

    public function down()
    {
        Schema::table('cours', function (Blueprint $table) {
            $table->dropUnique('cours_pdf_file_unique');
        });
    }
}
