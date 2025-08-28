<?php

namespace App\Http\Helpers;

class IfpbCalculator {

    public static function format($nombre){
        return strval(number_format( doubleval($nombre), 0, ',', ' '));
    } 

    public static function calculate($logement, $parameters){
        $coeff = 0;
        $parameter = [];
        $constructionParams = ['typequart', 'etatmur', 'access', 'typehab','typelog', 'toiture'];
        
        foreach ($constructionParams as $param) {
            $key = $logement[$param];
            if (isset($parameters[$param][$key])) {
                $coeff += $parameters[$param][$key];
                $parameter[] = $param.": ".$key."(".$parameters[$param][$key].")";
            }
        }

        $conforts = explode(", ", $logement->confort);
        $conf = "Confort: ";
        foreach ($conforts as $confort) {
            if (isset($parameters["confort"][$confort])) {
                $coeff += $parameters["confort"][$confort];
                $conf.= $confort."(".$parameters["confort"][$confort]."), ";
            }
        }

        $parameter[] = $conf;
        return [$coeff, $parameter];
    }

    public static function round($number) {
        $arrondi = round($number, -2);
        $reste = $arrondi % 100;
    
        return $reste != 0 ? ($reste > 50 ? $arrondi + (100 - $reste) : $arrondi - $reste) : $arrondi;
    }

    public static function getIfbpForTable($constructions, $parameters){
            $constructions = $constructions->map(function ($construction) use ($parameters) {
                $surface = $construction->surface;
                $construction->impot = 0;
                $construction->logements->transform(function ($logement) use ($construction, $parameters, $surface) {
                    if ($logement->forCalcul == 1) {
                        $logement->typequart = $construction->typequart;
                        $logement->etatmur = $construction->etatmur;
                        $logement->access = $construction->etatmur;
                        $logement->typehab = $construction->typehab;
                        $logement->toiture = $construction->toiture;
                        $logement->surface = $surface;
    
                        // Calcul de la somme des coefficients
                        [$logement->coefficient, $detail] = self::calculate($logement, $parameters);
                    
                        // Calcul de l'impôt par mois
                        $logement->impotPerMonth = $logement->coefficient * $surface;

                        // Calcul de l'abattement du logement si c'est une habitation propriétaire
                        if (in_array($logement->typeoccup, ["Propriétaire", "Occupant gratuit"])) {
                            $logement->impotPerMonth *= 0.3;
                        }

                        $impotPerYearWithoutTaux = $logement->impotPerMonth * 12;
                        $impotPerYear = $impotPerYearWithoutTaux * 0.05;
                        $logement->impotPerYearWithoutTaux = $impotPerYearWithoutTaux;
                        $logement->impotPerYear = $impotPerYear;
                        $construction->impot += $logement->impotPerYear;
                        return $logement;
                    }
                });
                // Minimum de perception est 5000ar
                $construction->impot = max($construction->impot, 5000);
                $construction->impot = self::round($construction->impot);
                
                return $construction;
            });
            
            $total = 0;
            for ($i=0; $i < count($constructions); $i++) { 
                $total+= $constructions[$i]->impot;
                $constructions[$i] = [
                    "article" => $constructions[$i]->newarticle,
                    "proprietaire" => $constructions[$i]->proprietaire != null ? trim($constructions[$i]->proprietaire->nomprop." ".$constructions[$i]->proprietaire->prenomprop) : "",
                    "adresse" => $constructions[$i]->adress,
                    "boriboritany" => $constructions[$i]->boriboritany,
                    "ifpb" => self::format($constructions[$i]->impot),
                    "payment" => $constructions[$i]->totalPayment,
                    "reste" =>  self::format($constructions[$i]->impot -  $constructions[$i]->totalPayment)
                ];
            }

            return [
                "total" => self::format($total),
                "constructions" => $constructions
            ];
    }

    public static function treat($constructions, $parameters, $image = true)
    {
        $constructions = $constructions->map(function ($construction) use ($parameters) {
            $surface = $construction->surface;
            $construction->impot = 0;
            $construction->logements->transform(function ($logement) use ($construction, $parameters, $surface) {
                if ($logement->forCalcul == 1) {
                    $logement->typequart = $construction->typequart;
                    $logement->etatmur = $construction->etatmur;
                    $logement->access = $construction->etatmur;
                    $logement->typehab = $construction->typehab;
                    $logement->toiture = $construction->toiture;
                    $logement->surface = $surface;

                    // Calcul de la somme des coefficients
                    [$logement->coefficient, $detail] = $this->calculate($logement, $parameters);
                    $detail[] = "Somme coefficient: " . $logement->coefficient;

                    // Calcul de l'impôt par mois
                    $logement->impotPerMonth = $logement->coefficient * $surface;
                    $detail[] = "Surface occupée: " . $surface . " m²";
                    $detail[] = "Niveau: " . $logement->niveau;
                    $detail[] = "Loyer mensuel: " . $logement->lm . " Ar";
                    $detail[] = "Impot(par défaut): " . $logement->coefficient . " x " . $surface . " = " . $logement->impotPerMonth;

                    // Calcul de l'abattement du logement si c'est une habitation propriétaire
                    if (in_array($logement->typeoccup, ["Propriétaire", "Occupant gratuit"])) {
                        $logement->impotPerMonth *= 0.3;
                        $detail[] = "Impot mensuel (abattement 70%): " . $logement->coefficient . " x " . $surface . " x 0.3 = " . $logement->impotPerMonth;
                    }
                    $impotPerYearWithoutTaux = $logement->impotPerMonth * 12;
                    $impotPerYear = $impotPerYearWithoutTaux * 0.05;
                    $logement->impotPerYearWithoutTaux = $impotPerYearWithoutTaux;
                    $logement->impotPerYear = $impotPerYear;
                    $logement->details = array_merge($detail, [
                        "Occupant: " . $logement->typeoccup,
                        "Impot mensuel: " . $logement->impotPerMonth . "(abattement 70%)" ?: "",
                        "Impot annuel: " . $impotPerYear,
                    ]);
                    $construction->impot += $logement->impotPerYear;

                    return $logement;
                }
            });
            // Minimum de perception est 5000ar
            $construction->impot = max($construction->impot, 5000);
            $construction->impot = $this->round($construction->impot);

            return $construction;
        });

        return $constructions;
    }
}