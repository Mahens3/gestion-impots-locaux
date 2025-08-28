<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ControlController extends Controller
{
    private function verifLog($numcons, $idagt, $nombre, $usage){
        set_time_limit(1000000);
        $logements = DB::table("logement")->where("numcons",$numcons)->get();
        $nbr=$nombre;
        if(count($logements)==0){    
            $this->insertLog($numcons, $idagt, $nombre, $usage);
            $nbr= $nbr+1;
             
        }
        return $nbr;
    }

    private function insertLog($numcons, $idagt, $nombre, $typelog){
        DB::table("logement")->insert([
            "numlog" => date("Ymdhis").$nombre."034".$idagt,
            "typeoccup" => "Propriétaire",
            "typelog" => $typelog,
            "stpp" => 0,
            "stps" => 0,
            "niveau" => "Rez de chaussée",
            "statut" => "Familial",
            "numcons" => $numcons,
            "confort" => "",
            "datetimes" => date("Y-m-d h:i:s"),
            "id" => $idagt]);
    }

    public function correctionImposable(){
        $construction=DB::table("construction")
                ->where("typecons","Imposable")
                ->where("surface",">",0)
                ->orderBy("idagt")
                ->get();
        $agt = 0;
        $nombre = 200;
        for($i=0; $i<count($construction); $i++){
            if($construction[$i]->idagt != $agt){
                $nombre = 200;
                $agt = $construction[$i]->idagt;
            }
            if($agt!=4){
                $nombre = $this->verifLog($construction[$i]->numcons, $agt, $nombre, "Habitat");
            }
            
        }
    }

    private function correctionImposableAutre(){
        $construction=DB::table("construction")
                ->orWhere('typecons', 'LIKE', "imposable (%")
                ->orWhere('typecons', 'LIKE', "imposable(%")
                ->orWhere('typecons', 'LIKE', "Imposable fa%")
                ->orWhere('typecons', 'LIKE', "imposable inactif%")
                ->orWhere('typecons', 'LIKE', "imposable mbola%")
                ->orWhere('typecons', 'LIKE', "imposable tsy%")
                ->orderBy("idagt")
                ->get();
        $agt = 0;
        $nombre = 80;
        for($i=0; $i<count($construction); $i++){
            if($construction[$i]->idagt != $agt){
                $nombre = 80;
                $agt = $construction[$i]->idagt;
            }
            $nombre = $this->verifLog($construction[$i]->numcons, $agt, $nombre , "Habitat");
            DB::table("construction")->where("numcons",$construction[$i]->numcons)->update(["typecons"=>"Imposable"]);
        }
    }

    private function correctionAutre(){
        $typecons = ["Ecole","ecole catholique", "École L-PRIM","École Privé les Liserons","École privé VIVA","ECOLE PRIVÉE LA PUISSANCE"];
        $usage = [
            "poiupoi" => "",
            "Chambre " => "Hôtellerie", 
            "CHAMBRE SOALANDY" => "Hôtellerie",
            "BAINGALOW" => "Hôtellerie",
            "Bureau" => "Bureau",
            "Bureau TIAVO" =>  	"Bureau",
            "Bureau Géomètre Expert" => "Bureau",
            "fivarotana" => "Commerce",
            "fivantanana" => "Habitat",
            "fandraisana vahiny" => "Habitat",
            "Commerce" => "Commerce",
            "Épicerie" => "Commerce",
            "épicerie 12" => "Commerce",
            "épicerie de" => "Commerce",
            "EPI BAR" => "Commerce",
            "EPI_ BAR" => "Commerce",
            "Gargottes" => "Commerce",
            "Gargotte" => "Commerce",
            "Inactif" => "Habitat",
            "Ex mangasin" => "Commerce",
            "ex-Epicerie" => "Commerce",
            "Tsy Misy Mpetraka hoe io" => "Habitat",
            "Tsy misy mipetraka tsony" => "Habitat",
            "Tsy ipetrahana tsony" => "Habitat",
            "tsisy olona mipetraka" => "Habitat",
            "USINE" => "Commerce",
            "Maison inactif" => "Habitat",
            "Mainson inactif" => "Habitat",
            "Maison innactif" => "Habitat",
            "maison non habiter" => "Habitat",
            "maison non utilise" => "Habitat",
            "maison non utilise lo" => "Habitat",
            "Maison Inactif" => "Habitat",
            "BIONEX" => "Bureau",
            "Collège Saint Vincent De Paul" => "Education",
            "Bar" => "Commerce",
            "dépôt" => "Dépôt",
            "depot d'entretien" => "Dépôt",
            "Dépôt de Médicaments Iavisoa" => "Dépôt",
            "dépôt de médicaments" => "Dépôt",
            "Depot de stocage" => "Dépôt",
            "Depot de stockage" => "Dépôt",
            "stockage" => "Dépôt",
            "stoquage" => "Dépôt",
            "Sans Personne" => "Habitat",
            "salle de video" => "Loisirs",
            "salle de stockage" => "Dépôt",
            "salle de jeux" => "Loisirs",
            "jeux" => "Loisirs",
            "salle de fête / reunion" => "Loisirs",
            "sallde de fête" => "Loisirs",
            "salle atelier" => "Commerce",
            "Petite stocage" => "Dépôt",
            "non utilise" => "Habitat",
            "Mangasin" => "Commerce",
            "Mangasin inactif" => "Commece",
            "Machine du riz" => "Commerce",
            "machine fitoton bary" => "Commerce",
            "Machine" => "Commerce",
            "fitotoambary" => "Commerce",
            "Magasin" => "Commerce",
            "hotel" => "Hôtellerie",
            "Logement pastoral" => "Habitat",
            "Logement personnel" => "Habitat",
            "Logement sans Personne" => "Habitat",
            "Logement sans Personne inactif" => "Habitat",
            "Magasin tsy miasa intsony" => "Commerce",
            "magasin tsy misy mivarotra" => "Commerce",
            "Maisson Inactif" => "Commerce",
            "maison de stock" => "Dépôt",
            "HOTELERIE" => "Hôtellerie",
            "Mangazay Fivarotana Mofo" => "Commerce",
            "Nouveau construction" => "Habitat",
            "Trano Fisy Entana" => "Dépôt",
            "Fisy Entana" => "Dépôt",
            "Trano tsy ipetrana" => "Habitat",
            "Trano tsy miasa" => "Habitat",
            "Trano tsy misy mipetraka aloha hatreto" => "Habitat",
            "trano tsy mosy mipetraka" => "Habitat",
            "trano vadim piangonana" => "Habitat",
            "magasin tsy misy mivarotra koa" => "Commece",
        ];

        $query = DB::table("construction");
        foreach(array_keys($usage) as $key){
            $query->orWhere("typecons", $key);
        }

        for($j=0; $j<count($typecons);$j++){
            $query->orWhere("typecons", $typecons[$j]);
        }

        $construction = $query->orderBy("idagt")->get();
        $us = "";
        $nombre = 100;
        $agt=0;
        for($i=0; $i<count($construction); $i++){
            if($construction[$i]->idagt != $agt){
                $nombre = 100;
                $agt = $construction[$i]->idagt;
            }
            if(isset($usage[$construction[$i]->typecons])){
                $us = $usage[$construction[$i]->typecons];
            }
            else{
                $us = "Education";
            }

            $nombre = $this->verifLog($construction[$i]->numcons, $agt, $nombre, $us);
            DB::table("construction")->where("numcons",$construction[$i]->numcons)->update(["typecons"=>"Imposable"]);
        }
    }

    // Bar
    // BIONEX
    // Collège Saint Vincent De Paul 

    public function correction(){
        set_time_limit(700000);
        $this->correctionImposableAutre();
        $this->correctionAutre();
        $this->correctionImposable();
    }
}
