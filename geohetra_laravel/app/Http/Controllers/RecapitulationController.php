<?php

namespace App\Http\Controllers;

use App\Models\Construction;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\CalculIFPB;

class RecapitulationController extends Controller
{
    public function index()
    {
        $calculateur = new CalculIFPB();
        set_time_limit(1000000000);

        $sommeIfpb = 0;
        $sommePayment = 0;

        $fokontany = DB::table("fokontany")->get();
        $impotPerFokontany = [];
        foreach ($fokontany as $foko) {
            $constructions = Construction::with("logements", "payments")->where("typecons", "Imposable")->where("idfoko", $foko->id)->get();
            $constructions = $calculateur->treat($constructions, false);

            $si = $this->sumIfpb($constructions);
            $pi = $this->sumPayment($constructions);

            $sommeIfpb += $si;
            $sommePayment += $pi;

            $impotPerFokontany[] = [
                "fokontany" => $foko->nomfokontany,
                "impot" => $si,
                "paye" => $pi,
                "reste" => $si - $pi,
            ];
        }
        
        return view("recapitulation", ["ifpb" => $sommeIfpb, "payments" => $sommePayment, "fokontany" => $impotPerFokontany]);
    }

    private function sumIfpb($constructions)
    {
        $somme = 0;
        foreach ($constructions as $construction) {
            $somme += $construction->impot;
        }
        return $somme;
    }

    private function sumPayment($constructions)
    {
        $somme = 0;
        foreach ($constructions as $construction) {
            foreach ($construction->payments as $payment) {
                $somme += $payment->montant;
            }
        }

        return $somme;
    }

}