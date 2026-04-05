<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InfoSup extends Model
{
    use HasFactory;
    protected $table = 'info_sups'; 

    protected $fillable = [
        'id_user', 
        'pays',    
        // ... autres champs ...
    ];
}
