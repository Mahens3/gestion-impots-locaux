<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Ifpb extends Model
{
    protected $table = 'ifpb';
    protected $primaryKey = 'numif';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = false;

    protected $fillable = [
        'numif',
        'exon',
        'dernanne',
        'montantins',
        'montantpay',
        'cause',
        'article',
        'id',
        'datetimes',
        'role',
    ];

    public function constructions()
    {
        return $this->hasMany(Construction::class, 'numif', 'numif');
    }
}
