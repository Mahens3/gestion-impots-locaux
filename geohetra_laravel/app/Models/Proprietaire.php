<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Proprietaire extends Model
{
    protected $table = 'proprietaire';
    protected $primaryKey = 'numprop';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = true;

    protected $fillable = [
        'numprop',
        'nomprop',
        'prenomprop',
        'propriete',
        'adress',
        'typeprop',
        'id',
        'datetimes',
        'created_at',
        'updated_at'
    ];

    public function constructions()
    {
        return $this->hasMany(Construction::class, 'numprop', 'numprop');
    }
}
