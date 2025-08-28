<?php
// mercredi8759
namespace App\Http\Controllers;

use App\Models\Payment;
use App\Models\Logement;
use App\Models\Fokontany;
use App\Models\Construction;
use App\Models\Proprietaire;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Intervention\Image\Facades\Image;
use Illuminate\Database\QueryException;

class FetchController extends Controller {
    private $parameters;
    private $months = [ '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Decembre' ];

    private function getParameters() {
        if ( $this->parameters ) {
            return $this->parameters;
        }
        $parameters = [];
        $results = DB::table( 'parametre' )->get();
        foreach ( $results as $parameter ) {
            if ( !isset( $parameters[ $parameter->colonne ] ) ) {
                $parameters[ $parameter->colonne ] = [];
            }
            $parameters[ $parameter->colonne ][ $parameter->valeur ] = $parameter->coeff;
        }
        $this->parameters = $parameters;
        return $parameters;
    }

    public function base64( $filename ) {
        if ( is_null( $filename ) ) {
            $path = public_path() . '/images/default.jpg';
        } else if ( file_exists( public_path() . '/images/' . $filename ) ) {
            $path = public_path() . '/images/' . $filename;
        } else {
            $path = public_path() . '/images/default.jpg';
        }

        $image = Image::make( $path )->resize( 500, null, function ( $constraint ) {
            $constraint->aspectRatio();
            $constraint->upsize();
        }
    );

    $data = ( string ) $image->encode();
    $base64 = base64_encode( $data );
    return $base64;
}

public function image( $filename ) {
    $path =  public_path( '/images/'.$filename );
    if ( !File::exists( $path ) ) {
        $path =  public_path( '/images/default.jpg' );
    }
    $file = File::get( $path );
    $type = File::mimeType( $path );
    return response()->make( $file, 200 )->header( 'Content-Type', $type );
}

private function calculate( $logement, $parameters ) {
    $coeff = 0;
    $parameter = [];
    $constructionParams = [ 'typequart', 'etatmur', 'access', 'typehab', 'typelog', 'toiture' ];
    foreach ( $constructionParams as $param ) {
        $key = $logement[ $param ];
        if ( isset( $parameters[ $param ][ $key ] ) ) {
            $coeff += $parameters[ $param ][ $key ];
            $parameter[] = $param.': '.$key.'('.$parameters[ $param ][ $key ].')';
        }
    }

    $conforts = explode( ', ', $logement->confort );
    $conf = 'Confort: ';
    foreach ( $conforts as $confort ) {
        if ( isset( $parameters[ 'confort' ][ $confort ] ) ) {
            $coeff += $parameters[ 'confort' ][ $confort ];
            $conf .= $confort.'('.$parameters[ 'confort' ][ $confort ].'), ';
        }
    }
    $parameter[] = $conf;
    return [ $coeff, $parameter ];
}

private function round( $number ) {
    $arrondi = round( $number, -2 );
    $reste = $arrondi % 100;

    return $reste != 0 ? ( $reste > 50 ? $arrondi + ( 100 - $reste ) : $arrondi - $reste ) : $arrondi;
}

private function treat( $constructions, $image = true ) {
    $parameters = $this->getParameters();

    $constructions = $constructions->map( function ( $construction ) use ( $parameters ) {
        $surface = $construction->surface;
        $construction->impot = 0;
        $construction->logements->transform( function ( $logement ) use ( $construction, $parameters, $surface ) {
            if ( $logement->forCalcul == 1 ) {
                $logement->typequart = $construction->typequart;
                $logement->etatmur = $construction->etatmur;
                $logement->access = $construction->etatmur;
                $logement->typehab = $construction->typehab;
                $logement->toiture = $construction->toiture;
                $logement->surface = $surface;

                // Calcul de la somme des coefficients
                [ $logement->coefficient, $detail ] = $this->calculate( $logement, $parameters );
                $detail[] = 'Somme coefficient: ' . $logement->coefficient;

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

    public function search($page,$value){
        $constructions = Construction::with("proprietaire", "logements", "ifpb", "personnes", "fokontany")
        ->orWhereHas("proprietaire", function($query) use ($value){
            $query->whereRaw("LOWER(CONCAT(nomprop,' ',prenomprop)) LIKE ?", ['%'.strtolower($value).'%']);
        })
        ->orWhereRaw("adress LIKE ? OR boriboritany LIKE ? AND typecons=?", ['%'.strtolower($value).'%', '%'.strtolower($value).'%', "Imposable"])
        ->paginate(24, ['*'],'page', $page);

        $total = $constructions->total();
        $currentPage = $constructions->currentPage();

        $fokontany = Fokontany::get();
        $constructions = $this->treat($constructions, false)->map(function ($construction){
            return [
                "numcons" => $construction->numcons,
                "article" => $construction->article,
                "val_impot" =>  $construction->impot,
                "impot" =>  $this->formatter($construction->impot),
                "position" =>  array_map("floatval",explode(", ", $construction->coord)),
                "proprietaire" => isset($construction->proprietaire) ?  $construction->proprietaire->nomprop." ".$construction->proprietaire->prenomprop : "",
                "niveau" => $construction->nbrniv,
                "geometry" => $construction->geometry,
                "reste" => $construction->impot - $construction->totalPayment,
                "paye" => $construction->totalPayment,
                "area" => $construction->area,
                "adresse" => trim($construction->adress." ".$construction->boriboritany),
                "fokontany" => $construction->fokontany->nomfokontany,
                "idfoko" => $construction->idfoko,
                "surface" => $construction->surface,
                "image" => $construction->image,  
            ];
        });

        $montant = 0;
        foreach ($constructions as $item) {
            $montant += $item["val_impot"];
        }

        return [
            "construction" => $constructions,
            "fokontany" => $fokontany,
            "currentPage" => $currentPage,
            "montant" => $this->formatter($montant),
            "total" => $total
        ];
    }

    public function findDefault($page)
    {
        $constructions = Construction::with("proprietaire", "logements", "ifpb", "personnes", "fokontany")
        ->where("typecons", "Imposable")
        ->paginate(24, ['*'],'page', $page);

        $total = $constructions->total();
        $currentPage = $constructions->currentPage();
        
        $fokontany = Fokontany::get();
        $constructions = $this->treat($constructions, false)->map(function ($construction) {
            //$this->copyFile($construction->image);
            return [
                "numcons" => $construction->numcons,
                "article" => $construction->article,
                "val_impot" => $construction->impot,
                "impot" =>  $this->formatter($construction->impot),
                "position" =>  array_map("floatval",explode(", ", $construction->coord)),
                "proprietaire" => isset($construction->proprietaire) ?  $construction->proprietaire->nomprop." ".$construction->proprietaire->prenomprop : "",
                "niveau" => $construction->nbrniv,
                "geometry" => $construction->geometry,
                "reste" => $construction->impot - $construction->totalPayment,
                "paye" => $construction->totalPayment,
                "area" => $construction->area,
                "toiture" => $construction->toiture,
                "mur" => $construction->mur,
                "adresse" => trim($construction->adress." ".$construction->boriboritany),
                "fokontany" => $construction->fokontany->nomfokontany,
                "idfoko" => $construction->idfoko,
                "surface" => $construction->surface,
                "image" => $construction->image,  
            ];
        });

        $montant = 0;
        foreach ($constructions as $item) {
            $montant += $item["val_impot"];
        }

        return [
            "construction" => $constructions,
            "fokontany" => $fokontany,
            "currentPage" => $currentPage,
            "montant" =>  $this->formatter($montant),
            "total" => $total
        ];
    }
 
    public function findForMap($id)
    {
        $constructions = Construction::with("proprietaire", "fokontany")
            ->where("typecons", "Imposable")
            ->whereNotNull("coord");

        $fokontany = Fokontany::get();
        if($id>0){
            $constructions->where("idfoko", $id);
        }
        
        $constructions = ($this->treat($constructions->orderBy("created_at", "DESC")->get(), false))->map(function ($construction){
            return [
                "numcons" => $construction->numcons,
                "article" => $construction->article,
                "impot" =>  $this->formatter($construction->impot),
                "position" =>  array_map("floatval",explode(",", $construction->coord)),
                "proprietaire" => isset($construction->proprietaire) ?  $construction->proprietaire->nomprop." ".$construction->proprietaire->prenomprop : "",
                "niveau" => $construction->nbrniv,
                "geometry" => json_decode($construction->geometry),
                "area" => $construction->area,
                "adresse" => trim($construction->adress." ".$construction->boriboritany),
                "fokontany" => $construction->fokontany->nomfokontany,
                "idfoko" => $construction->idfoko,
                "surface" => $construction->surface,
                "date" => $construction->datetimes,
                "agent" => $construction->idagt,
                "image" => $construction->image,  
            ];
        });

        return [
            "construction" => $constructions,
        ];
    }

    public function findAllForAvis($page, $nbrPerPage, $fokontany)
    {
        $constructions = Construction::with("proprietaire", "logements", "ifpb", "personnes", "fokontany")
        ->where("typecons", "Imposable")
        ->orderBy("idfoko");
        if($fokontany>0){
            $constructions = $constructions->where("idfoko", $fokontany);
        }

        $constructions = $constructions->paginate($nbrPerPage, ['*'],'page', $page);
        $total = $constructions->total();
        $currentPage = $constructions->currentPage();

        $fokontany = Fokontany::get();
        $constructions = $this->treat($constructions, false);

        return [
            "construction" => $constructions,
            "fokontany" => $fokontany,
            "currentPage" => $currentPage,
            "total" => $total
        ];
    }

    public function paymentsByMonth()
    {
        $availableMonths = Payment::select(
            DB::raw('YEAR( datePayment ) as year'),
            DB::raw('MONTH( datePayment ) as month')
        )
            ->groupBy('year', 'month')
            ->get();
    
        $allMonths = [];
        foreach ($availableMonths as $month) {
            $year = $month->year;
            $monthNumber = $month->month;
            $allMonths["$monthNumber"] = [
                'year' => $year,
                "month_number" => $monthNumber,
                'month' => $this->months[intval($month->month)], // Utilisez la valeur par défaut si le mois n'est pas défini
                'amount' => 0,
            ];
        }
        $paymentsByMonth = Payment::select(
            DB::raw( 'YEAR(datePayment) as year' ),
            DB::raw( 'MONTH(datePayment) as month' ),
            DB::raw( 'SUM(montant) as amount' )
        )
        ->groupBy( 'year', 'month' )
        ->get();

        foreach ( $paymentsByMonth as $payment ) {
            $year = $payment->year;
            $allMonths[ "$payment->month" ][ 'amount' ] = intval( $payment->amount );
        }

        for ( $i = 1; $i<13; $i++ ) {
            if ( !isset( $allMonths[ "$i" ] ) ) {
                $allMonths[ "$i" ] = [
                    'year' => '',
                    'month' => $this->months[ $i ],
                    'amount' => 0,
                ];
            }

        }
        ksort( $allMonths );
        return ( array_values( $allMonths ) );
    }

    public function dashboard() {
        $fokontany = Fokontany::get();
        $data = [];

        $totalConstruction = 0;
        $totalIfpb = 0;
        $totalPaiement = 0;
        $totalConstPaye = 0;

        foreach ( $fokontany as $foko ) {
            $constructions = Construction::where( 'typecons', 'Imposable' )
            ->with( 'logements' )->where( 'idfoko', $foko->id )->get();

            $constructions = $this->treat( $constructions, false );

            $ifpb = $constructions->sum( 'impot' );
            $paiement = $constructions->sum( 'totalPayment' );
            $consPaye = $constructions->filter( function( $construction ) {
                return $construction->totalPayment == $construction->impot;
            }
        )->count();

        $totalConstruction += $constructions->count();
        $totalIfpb += $ifpb;
        $totalPaiement += $paiement;
        $totalConstPaye += $consPaye;

        $data[] = [
            'id' => $foko->id,
            'fkt' => $foko->nomfokontany,
            'z' => $paiement,
            'y' => $ifpb,
            'consPaye' => $consPaye,
            'count' => $constructions->count()
        ];
    }

    return [
        'dataBar' => $data,
        'dataSpline' => $this->paymentsByMonth(),
        'construction' => $totalConstruction,
        'ifpb' => $totalIfpb,
        'paiement' => $totalPaiement,
        'consPaye' => $totalConstPaye
    ];

}

public function dashboardEnq() {
    $fokontany = Fokontany::get();
    $data = [];

    $totalConstruction = Construction::get();
    $totalImposable = Construction::where( 'typecons', 'Imposable' )->get();
    $totalIncompelete = Construction::whereNull( 'typecons' )->get();
    $totalReste = count( $totalConstruction ) - count( $totalImposable ) - count( $totalIncompelete );

    foreach ( $fokontany as $foko ) {
        $imposable = Construction::where( 'idfoko', $foko->id )->where( 'typecons', 'Imposable' )->get();
        $construction = Construction::where( 'idfoko', $foko->id )->get();
        $data[] = [
            'id' => $foko->id,
            'fkt' => $foko->nomfokontany,
            'z' => count( $imposable ),
            'y' => count( $construction )
        ];
    }

    return [
        'dataBar' => $data,
        'construction' => count( $totalConstruction ),
        'imposable' => count( $totalImposable ),
        'incomplete' => count( $totalIncompelete ),
        'autre' => $totalReste
    ];

}

public function minPerception( $ui, $impot ) {
    $array = $ui;
    $type = [ 'HP', 'AUP', 'HT', 'AUT' ];
    $sum = 0;
    for ( $i = 0; $i<count( $type );
    $i++ ) {
        $sum += $array[ $type[ $i ] ][ 'ifpb' ];

    }

    $reste = $impot - $sum;

    for ( $i = 0; $i<count( $type );
    $i++ ) {
        if ( $array[ $type[ $i ] ][ 'ifpb' ]>0 ) {
            $array[ $type[ $i ] ][ 'ifpb' ] = $array[ $type[ $i ] ][ 'ifpb' ] + $reste;
            break;
        }

    }
    return $array;
}

public function recapitulation() {
    $constructions = Construction::with( 'logements' )
    ->where( 'typecons', 'Imposable' )->get();

    $types = [
        'HP' => [
            'ifpb' => 0,
            'nombre' => 0,
        ],
        'AUP'  => [
            'ifpb' => 0,
            'nombre' => 0,
        ],
        'HT' => [
            'ifpb' => 0,
            'nombre' => 0,
        ],
        'AUT'  => [
            'ifpb' => 0,
            'nombre' => 0,
        ],
        'total' => [
            'ifpb' => 0,
            'nombre' => 0,
        ]
    ];

    $parameters = $this->getParameters();

    $constructions = $constructions->map( function ( $construction ) use ( $parameters, $types ) {
        $surface = $construction->surface;
        $construction->impot = 0;
        $typelogs = [
            'HP' => [
                'ifpb' => 0,
                'nombre' => 0,
            ],
            'AUP'  => [
                'ifpb' => 0,
                'nombre' => 0,
            ],
            'HT' => [
                'ifpb' => 0,
                'nombre' => 0,
            ],
            'AUT'  => [
                'ifpb' => 0,
                'nombre' => 0,
            ]
        ];

        $construction->logements->transform( function ( $logement ) use ( $construction, $parameters, $surface, $typelogs ) {

            if ( $logement->forCalcul == 1 ) {
                $logement->typequart = $construction->typequart;
                $logement->etatmur = $construction->etatmur;
                $logement->access = $construction->etatmur;
                $logement->typehab = $construction->typehab;
                $logement->toiture = $construction->toiture;
                $logement->surface = $surface;

                // Calcul de la somme des coefficients
                [ $logement->coefficient, $detail ] = $this->calculate( $logement, $parameters );

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

            foreach($construction->logements as $logement) {
                if($logement!=null && $logement["forCalcul"]==1){
                    if($logement["typeoccup"] == "Propriétaire"){
                        if($logement["typelog"]=="Habitat"){
                            $typelogs["HP"]["ifpb"] += $logement["impotPerYear"];
                            $typelogs["HP"]["nombre"] += 1;
                        }
                        else{
                            $typelogs["AUP"]["ifpb"] += $logement["impotPerYear"];
                            $typelogs["AUP"]["nombre"] +=1;
                        }
                    }
                    else{
                        if($logement["typelog"]=="Habitat"){
                            $typelogs["HT"]["ifpb"] += $logement["impotPerYear"];
                            $typelogs["HT"]["nombre"] += 1;
                        }
                        else{
                            $typelogs["AUT"]["ifpb"] += $logement["impotPerYear"];
                            $typelogs["AUT"]["nombre"] += 1;
                        }
                    }
                }
            }

            $construction->impot = max($construction->impot, 5000);
            $construction->impot = $this->round($construction->impot);

            $construction->ifpb = $this->minPerception($typelogs, $construction->impot);
        

            return $construction;
        });

        foreach ($constructions as $construction) {
            $types["HP"]["ifpb"] += ($construction->ifpb["HP"]["ifpb"]);
            $types["AUP"]["ifpb"] += ($construction->ifpb["AUP"]["ifpb"]);
            $types["HT"]["ifpb"] += ($construction->ifpb["HT"]["ifpb"]);
            $types["AUT"]["ifpb"] += ($construction->ifpb["AUT"]["ifpb"]);
            $types["total"]["ifpb"] += ($construction->ifpb["HP"]["ifpb"]) + ($construction->ifpb["AUP"]["ifpb"]) + ($construction->ifpb["HT"]["ifpb"]) + ($construction->ifpb["AUT"]["ifpb"]);
        
            $types["HP"]["nombre"] += ($construction->ifpb["HP"]["nombre"]);
            $types["AUP"]["nombre"] += ($construction->ifpb["AUP"]["nombre"]);
            $types["HT"]["nombre"] += ($construction->ifpb["HT"]["nombre"]);
            $types["AUT"]["nombre"] += ($construction->ifpb["AUT"]["nombre"]);
            $types["total"]["nombre"] += ($construction->ifpb["HP"]["nombre"]) + ($construction->ifpb["AUP"]["nombre"]) + ($construction->ifpb["HT"]["nombre"]) + ($construction->ifpb["AUT"]["nombre"]);
        
        }

        return [
            "HP" => [
                "ifpb" => $this->formatter($types["HP"]["ifpb"]),
                "nombre" => $types["HP"]["nombre"]
            ],
            "AUP" => [
                "ifpb" => $this->formatter($types["AUP"]["ifpb"]),
                "nombre" => $types["AUP"]["nombre"]
            ],
            "HT" =>[
                "ifpb" => $this->formatter($types["HT"]["ifpb"]),
                "nombre" => $types["HT"]["nombre"]
            ],
            "AUT" => [
                "ifpb" => $this->formatter($types["AUT"]["ifpb"]),
                "nombre" => $types["AUT"]["nombre"]
            ],
            "Total" =>[
                "ifpb" => $this->formatter($types["total"]["ifpb"]),
                "nombre" => $types["total"]["nombre"]
            ],
        ];
    }
    

    public function find($id)
    {
        $constructions = Construction::where("numcons", $id)
            ->with("proprietaire","payments", "logements", "ifpb", "personnes", "fokontany")
            ->get();
        $constructions = $this->treat($constructions, false);
        $fokontany = Fokontany::get();

        return [
           "construction" =>  $constructions->first(),
           "fokontany" => $fokontany,
           "total" => 1
        ];
    }
    
    public function formatter($nombre){
        return strval(number_format( doubleval($nombre), 0, ', ', ' ' ) );
            }

        }