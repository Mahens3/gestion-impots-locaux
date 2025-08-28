<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Logement extends Model
{
    protected $table = 'logement';
    protected $primaryKey = 'numlog';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = true;

    protected $fillable = [
        'numlog',
        'nbrres',
        'niveau',
        'statut',
        'typelog',
        'typeoccup',
        'vlmeprop',
        'vve',
        'lm',
        'vlmeoc',
        'confort',
        'phone',
        'valrec',
        'nbrpp',
        'stpp',
        'nbrps',
        'stps',
        'numcons',
        'datetimes',
        'id',
        'declarant',
        'lien',
        'forCalcul',
        'created_at',
        'updated_at'
    ];

    public function construction()
    {
        return $this->belongsTo(Construction::class, 'numcons', 'numcons');
    }
}
