<?php

namespace App\Http\Controllers;

use App\Models\Construction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Helpers\IfpbCalculator;

class ProcessController extends Controller
{   
    private function getParameters()
    {
        $parameters = [];
        $results = DB::table("parametre")->get();
        foreach ($results as $parameter) {
            if (!isset($parameters[$parameter->colonne])) {
                $parameters[$parameter->colonne] = [];
            }
            $parameters[$parameter->colonne][$parameter->valeur] = $parameter->coeff;
        }
        return $parameters;
    }

    public function getIfpbByFokontany($idfoko){
        $parameters = $this->getParameters();

        $constructions = Construction::with("proprietaire","logements", "payments")
        ->where("idfoko", $idfoko)
        ->where("typecons", "Imposable")
        ->get();
        return IfpbCalculator::getIfbpForTable($constructions, $parameters);
    }
}
