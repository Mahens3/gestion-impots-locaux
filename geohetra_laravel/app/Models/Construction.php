<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Construction extends Model
{
    protected $table = 'construction';
    protected $primaryKey = 'numcons';
    public $incrementing = false;
    protected $keyType = 'string';
    public $timestamps = true;
    protected $appends = ["totalPayment", "loyer", "logs"];


    protected $fillable = [
        'numcons',
        'idcoord',
        'mur',
        'ossature',
        'toiture',
        'fondation',
        'typehab',
        'etatmur',
        'access',
        'nbrhab',
        'nbrniv',
        'anconst',
        'nbrcom',
        'nbrbur',
        'nbrprop',
        'nbrloc',
        'nbrocgrat',
        'surface',
        'coord',
        'numter',
        'numif',
        'numprop',
        'id',
        'idfoko',
        'datetimes',
        'adress',
        'image',
        'article',
        'geometry',
        'area',
        'numfiche',
        'newarticle',
        'created_at',
        'updated_at'
    ];

    public function proprietaire()
    {
        return $this->belongsTo(Proprietaire::class, 'numprop', 'numprop');
    }

    public function ifpb()
    {
        return $this->belongsTo(Ifpb::class, 'numif', 'numif');
    }

    public function logements()
    {
        return $this->hasMany(Logement::class, 'numcons', 'numcons');
    }

    public function personnes()
    {
        return $this->hasMany(Personne::class, 'numpers', 'numpers');
    }

    public function fokontany()
    {   
        return $this->belongsTo(Fokontany::class, 'idfoko', 'id');
    }

    public function agent()
    {   
        return $this->belongsTo(Agent::class, 'idagt', 'id');
    }

    public function payments()
    {   
        return $this->hasMany(Payment::class, 'numcons', 'numcons');
    }

    public function getTotalPaymentAttribute(){
        $total = 0;
        foreach($this->payments as $payment){
            $total+=$payment->montant;
        }
        return $total;
    }

    public function getLogsAttribute(){
        $logements = [];
        foreach($this->logements as $logement){
            if($logement!=null && $logement->forCalcul==1){
                $logements[] = $logement;
            }
        }
        return $logements;
    }

    public function getLoyerAttribute(){
        $lm = 0;
        foreach($this->logements as $logement){
            if($logement!=null){
                $lm+= $logement->lm==null ? 0 : $logement->lm;
            }
        }
        return $lm;
    }


}
