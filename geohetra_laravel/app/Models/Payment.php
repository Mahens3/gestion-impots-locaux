<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $table = 'payment';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'integer';
    public $timestamps = false;

    protected $fillable = [
        'id',
        'datePayment',
        'timePayment',
        'montant',
        'quittance',
        'numcons'
    ];

    public function construction()
    {
        return $this->belongsTo(Construction::class, 'numcons', 'numcons');
    }
}
