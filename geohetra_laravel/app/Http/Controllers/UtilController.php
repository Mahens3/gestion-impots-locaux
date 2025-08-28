<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UtilController extends Controller
{
      /** 
    public function findDefault($id)
{
    $constructions = Construction::where("typecons", "Imposable")
        ->with("proprietaire", "fokontany");
        ->where("idfoko", $id);
    if ($id > 0) {
        $constructions->where("idfoko", $id);
    }

    $constructions = $constructions->get()->map(function ($construction) {
        return [
            'type' => 'Feature',
            'geometry' => [
                'type' => 'Point',
                'coordinates' => array_reverse(array_map('floatval', explode(", ", $construction->coord))),
            ],
            'properties' => [
                "numcons" => $construction->numcons,
                "article" => $construction->article,
                "numprop" => $construction->numprop,
                "niveau" => $construction->nbrniv,
                "adresse" => $construction->adress,
                "boriboritany" => $construction->boriboritany,
                "fokontany" => $construction->fokontany->nomfokontany,
                "idfoko" => $construction->idfoko,
                "surface" => $construction->surface,
                "area" => 0,
                "image" => $construction->image,
            ],
        ];
    });

    $geojson = [
        'type' => 'FeatureCollection',
        'features' => $constructions,
    ];

    return $geojson;
}
 public function adding(Request $request){
        set_time_limit(9999999999999);
        $filePath = public_path('hetra.csv');
        $handle = fopen($filePath, 'r');
        while(($row=fgetcsv($handle,1000, ";")) !==false){
            $data = [];
            $row[1] = str_replace("MULTIPOLYGON(((", "", $row[1]);
            $row[1] = str_replace(")))", "", $row[1] );
            $geometry =  array_map(function($r){
                return array_reverse(array_map('floatval',explode(" ", $r)));
            },  explode(',', $row[1]));
            $data["geometry"] = json_encode($geometry);
            $data["area"] = floatval($row[2]);
            DB::table("construction")->where("numcons", substr($row[0],1))->update($data);
        }
        fclose($handle);
    }
*/


public function findByNumcons($array)
{
    set_time_limit(100000000);
    $array = json_decode($array);
    $constructions = Construction::with("proprietaire", "logements", "ifpb", "personnes", "fokontany");
    foreach ($array as $key) {
        $constructions->orWhere("numcons", $key);
    }
    $constructions = $this->treat($constructions->get());
    return response()->json($constructions);
}

public function adding(Request $request){
    set_time_limit(9999999999999);
    $constructions = Construction::where("typecons", "Imposable")
    ->with("proprietaire", "fokontany")
    ->where("idfoko", 3)->get();

    foreach($constructions as $construction){
        $surface = 1;
        $surface_array = explode(".", strval($construction->surface));
        foreach($surface_array as $surf){
            $surface*=intval($surf);
        }
        DB::table("construction")->where("numcons", $construction->numcons)->update([
            "surface" => $surface
        ]);
    }


    public function findByNumcons($array)
    {
        set_time_limit(100000000);
        $array = json_decode($array);
        $constructions = Construction::with("proprietaire", "logements", "ifpb", "personnes", "fokontany");
        foreach ($array as $key) {
            $constructions->orWhere("numcons", $key);
        }
        $constructions = $this->treat($constructions->get());
        return response()->json($constructions);
    }

    public function addProprietaire($data)
    {
        $count = 0;
        $array = [];

        for ($i = 0; $i < count($data); $i++) {
            try {
                DB::table('proprietaire')->insert([
                    'numprop' => $data[$i]["numprop"],
                    'nomprop' => $data[$i]["nomprop"],
                    'prenomprop' => $data[$i]["prenomprop"],
                    'adress' => $data[$i]["adress"],
                    'datetimes' => $data[$i]["datetimes"],
                ]);
                $count += 1;
            } catch (QueryException $e) {
                $count += 1;
                $array[] = $e;
            }
        }
        return $array;
    }

    public function addIfpb($data)
    {
        $array = [];
        for ($i = 0; $i < count($data); $i++) {
            try {
                DB::table('ifpb')->insert([
                    'numif' => $data[$i]["numif"],
                    'exon' => $data[$i]["exon"],
                    'dernanne' => $data[$i]["dernanne"],
                    'montantins' => $data[$i]["montantins"],
                    'montantpay' => $data[$i]["montantpay"],
                    'article' => $data[$i]["article"],
                    'role' => $data[$i]["role"],
                    'cause' => $data[$i]["cause"]
                ]);
            } catch (QueryException $e) {
                $array[] = $e;
            }
        }

        return $array;
    }

    public function addLogement($data)
    {
        $array = [];
        for ($i = 0; $i < count($data); $i++) {
            try {
                DB::table('logement')->insert([
                    'numlog' => $data[$i]["numlog"],
                    'nbrres' => $data[$i]["nbrres"],
                    'niveau' => $data[$i]["niveau"],
                    'statut' => $data[$i]["statut"],
                    'typelog' => $data[$i]["typelog"],
                    'typeoccup' => $data[$i]["typeoccup"],
                    'vlmeprop' => $data[$i]["vlmeprop"],
                    'vve' => $data[$i]["vve"],
                    'lm' => $data[$i]["lm"],
                    'vlmeoc' => $data[$i]["vlmeoc"],
                    'confort' => $data[$i]["confort"],
                    'valrec' => $data[$i]["valrec"],
                    'nbrpp' => $data[$i]["nbrpp"],
                    'stpp' => $data[$i]["stpp"],
                    'nbrps' => $data[$i]["nbrps"],
                    'stps' => $data[$i]["stps"],
                    'datetimes' => $data[$i]["datetimes"],
                    'numcons' => $data[$i]["numcons"],
                ]);
            } catch (QueryException $e) {
                $array[] = $e;
            }
        }

        return $array;
    }

    public function addPropr(Request $request)
    {
        $data = $request->data;
        for ($i = 0; $i < count($data); $i++) {
            $numprop = date("Ymd") . date("hm") . "03456" . $i;
            try {
                DB::table('proprietaire')->insert([
                    'numprop' => $numprop,
                    'nomprop' => $data[$i]["nomprop"],
                    'adress' => $data[$i]["adress"]
                ]);
            } catch (QueryException $e) {}

            DB::table('construction')->where("article", strval($data[$i]["article"]))->update([
                'numprop' => $numprop
            ]);
        }
    }

    public function completeLogement(Request $request)
    {
        set_time_limit(10000000900000);
        $data = Construction::with("logements")->where("typecons","Imposable")->get();
        $count = 1;
        foreach($data as $construction){
            if(count($construction->logements)==0){
                DB::table('logement')->insert([
                    'numlog' => date("Ymd") . date("his") . $count,
                    'nbrres' => 1,
                    'niveau' => "Rez de chaussée",
                    'statut' => "Familial",
                    'typelog' => "Habitat",
                    'typeoccup' => "Propriétaire",
                    'confort' => "",
                    'numcons' => $construction->numcons,
                ]);
            }
            $count+=1;
        }
    }

    public function addConstruction($data)
    {
       
    }

    public function normaliser(){
        
        $donnee = [];
        $result = DB::table("data2022")->get();
        for($i=0; $i<count($result); $i++){
            $data = $result[$i];
            $response = Construction::with("proprietaire", "fokontany")
            ->whereRaw("REPLACE(adress,' ','')".' like "'.str_replace(" ","",$data->ANCIEN_LOT).'%"')
            ->whereRaw('adress not like "PRES%"')
            ->whereRaw('adress like "I%"')
            ->where('adress', '!=', "")
            ->whereNotNull('adress')
            ->whereNull("numprop")
            ->get();
            if(count($response)>0 && trim($data->ANCIEN_LOT)!="" && $data->ANCIEN_LOT!=null){
                $array = [
                    "numcons" => $response[0]->numcons,
                    "nomprop" => $data->NOM,
                    "adress" => $response[0]->adress ." - ".$data->ANCIEN_LOT
                ];
                $donnee[] = $array;
            }
        }
        return $donnee;
      
        // COMPLETE PROPRIETAIRE ET ADRESS
        /**
        $donnee = [];
        $result = DB::table("data2022")->get();
        set_time_limit(100000000000000);
        for($i=0; $i<count($result); $i++){
            $data = $result[$i];
            $response = Construction::with("proprietaire", "fokontany")
            ->whereHas("fokontany", function($query) use ($data){
               $query->whereRaw("LOWER(nomfokontany)=?", [$data->FKT]);
            })
            ->whereHas("proprietaire", function($query) use ($data){
                $query->whereRaw("LOWER(CONCAT(nomprop,' ', prenomprop))=?", [$data->NOM]);
            })
            ->where("adress", "")
            ->whereNull("adress")
            ->get();

            if(count($response)>0){
                $array = [
                    "numcons" => $response[0]->numcons,
                    "nomprop" => $data->NOM,
                    "adress" => $data->ANCIEN_LOT
                ];
                $donnee[] = $array;
            }
        }
        return $donnee;
        */

      
    }

    public function updating() {
        $data = [];
        
        for($i=0; $i<count($data); $i++){
            $proprietaire = $this->getprop($data[$i], $i);
            $numprop = Proprietaire::create($proprietaire);
            DB::table("construction")->where("numcons", $data[$i]["numcons"])
            ->update([
                "numprop" => $proprietaire["numprop"]
            ]);
        }
    }

    public function getprop($value, $i){
        $splitted = explode(" ", trim($value["nomprop"]));
        $prenom = "";

        $numprop = date("Ymdhis".$i);
        for($i=1; $i<count($splitted); $i++){
            $splitted[$i] = strtolower($splitted[$i]);
            $prenom.= isset($splitted[$i][0]) ? strtoupper($splitted[$i][0]).substr($splitted[$i], 1)." " : "";
        }
        return [
            "numprop" => $numprop,
            "nomprop" => $splitted[0],
            "prenomprop" => trim($prenom)
        ];
    }

    public function copyFile($filename){
        if (is_null($filename)) {
            return false;
        } else if (file_exists(public_path() . '/images/' . $filename)) {
           copy(public_path() . '/images/' . $filename, public_path() . '/img/' . $filename);
           return true;
        } else {
            return false;
        }
    }

    public function getData($array)
    {
        $response = [["Proprietaire", "Adresse","Boriboritany", "Surf", "Niv",'Impot']];
        //$response = [["n°","id","surface","impot","mur","etatmur","ossature","toiture","fondation","typehab","nom_proprietaire","prenom_proprietaire","idprop","article","role","idifpb","habprop","nbrres","nbr_personne"]];
        for ($i = 1; $i < count($array); $i++) {
            if(isset($array[$i - 1]->agent->numequip)){
                $response[$i] = [
                    ($array[$i - 1]->proprietaire)==null ? "" : ($array[$i - 1]->proprietaire->nomprop) . " " . ($array[$i - 1]->proprietaire->prenomprop),
                    ($array[$i - 1]->adress),
                    ($array[$i - 1]->boriboritany),
                    ($array[$i - 1]->surface),
                    ($array[$i - 1]->nbrniv),
                    "'".$this->formatter($array[$i - 1]->impot),   
                ];
            }
            
        }

        return $response;
    }
}
public function total(){
    $fokontany = Fokontany::get();
    $mydata = [];
    foreach($fokontany as $foko){
        $constructions = Construction::where("typecons", "Imposable")
        ->with("logements")->where("idfoko", $foko->id)->get();
        $sum = 0;
        $constructions = $this->treat($constructions, false);
        foreach($constructions as $construction){
            $sum+=$construction->impot;
        }

        $mydata[] = [
            $foko->nomfokontany,
            $sum,
            count($constructions)
        ];
    }

    $csv = fopen("recap.csv", "w");
    fputs($csv, $bom = (chr(0xEF) . chr(0xBB) . chr(0xBF)));
    foreach ($mydata as $row) {
        fputcsv($csv, $row, ";");
    }
    fclose($csv);
    return $mydata;   
}


public function correction(){
    set_time_limit(999999999999999);
    $constructions = Construction::with("logements","fokontany","proprietaire")->where("typecons","Imposable")

    ->get();
    $dataniveau = ["Rez de chaussée", "1e étage", "2e étage", "3e étage", "4e étage", "5e étage"];
    $dataconfort = ["Garage", "Ecran plat", "Wifi", "Parabole", "WC interne", "Douche interne", "Salle d'eau", "Eau", "Electricité", "Cuisine interne", "Evacuation des eaux usées"];
    
    $u=0;
    for($i=0;$i<count($constructions); $i++){
        $newLogements = [];
        $logements = $constructions[$i]->logements;
        foreach ($logements as $logement) {
            if( !isset($newLogements[$logement->niveau]) ){
                $newLogements[$logement->niveau] = $logement->toArray();
                $newLogements[$logement->niveau]["forCalcul"] = true;
                $newLogements[$logement->niveau]["numlog"] = date("YmdHis".$u);
                $u+=1;
            }
            else{
                $confort = $newLogements[$logement->niveau]["confort"];
                $confort = $this->hasConfort($confort, $logement->confort, $constructions[$i]->typehab);
                $newLogements[$logement->niveau]["confort"] = $confort;
            }
        }

        $u+=1;

        for($j=0; $j<$constructions[$i]->nbrniv; $j++){
            $key = $dataniveau[$j];
            if(!isset($newLogements[$key])){
                $newLogements[$key] = [
                    'numlog' => date("YmdHis".$u.$j),
                    'niveau' => $key,
                    'statut' => "Familial",
                    'typelog' => "Habitat",
                    'stpp'=> 0,
                    'numcons' => $constructions[$i]->numcons,
                    'forCalcul' => true,
                    'typeoccup' => "Propriétaire",
                    'confort' => ""
                ];
                $u+=1;
            }
        }

        $logs = [];
        foreach ($newLogements as $key) {
            $logs[] = $key;
        }
        foreach ($logs as $log) {
            Logement::create($log);
        }
    }

    return "success";
}
public function hasConfort($value1, $value2, $typehab){
    $array1 = array_map("trim",explode(",", $value1));
    $array2 = array_map("trim", explode(",", $value2));

    $merge = array_merge($array1, $array2);
    $merge = array_unique($merge);

    if($typehab != "Haut standing"){
        $elementToRemove = "Cuisine interne";
        $merge = array_diff($merge, array($elementToRemove));
    }

    return implode(", ", $merge);
}  public function createCsvFile()
{
    set_time_limit(100000000000);
    $constructions = DB::table("reste")->get();

    //dd($constructions);
    $data = $this->getData($constructions);
    $csv = fopen("reste.csv", "w");
    fputs($csv, $bom = (chr(0xEF) . chr(0xBB) . chr(0xBF)));
    foreach ($data as $row) {
        fputcsv($csv, $row, ";");
    }
    fclose($csv);
}


public function correctionLog(){
    set_time_limit(999999999999999);
    $dataniveau = ["","Rez de chaussée", "1e étage", "2e étage", "3e étage", "4e étage", "5e étage"];
    
    $logements = Logement::with("construction.fokontany")->whereHas("construction", function($query){
        $query->whereRaw("typecons=?", ["Imposable"]);
    })->get();
    
    foreach($logements as $logement){
        $index = array_search($logement->niveau, $dataniveau);
        if(($logement->construction->nbrniv) < $index){
            dd("yes");
            /**
            DB::table("logement")->where("numlog", $logement->numlog)->update([
                "niveau" => $dataniveau[$index - 1]
            ]);
             */
        }
    }
}
}

