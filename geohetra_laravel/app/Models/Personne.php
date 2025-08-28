<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Personne extends Model
{
    protected $table = 'personne';
    protected $primaryKey = 'numpers';
    public $timestamps = false;

    protected $fillable = [
        'numpers',
        'sexe',
        'age',
        'profession',
        'lieu',
        'datetimes',
        'numcons',
        'id',
    ];

    public function construction()
    {
        return $this->belongsTo(Construction::class, 'numcons', 'numcons');
    }
}
