<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coordonnees extends Model
{
    protected $table = 'coordonnees';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'lat',
        'lng',
        'typequart',
        'etat',
        'dateattr',
        'dateret',
        'idfoko',
        'idagt',
    ];
}
