<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fokontany extends Model
{
    protected $table = 'fokontany';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'nomfokontany',
        'rang',
    ];
}
