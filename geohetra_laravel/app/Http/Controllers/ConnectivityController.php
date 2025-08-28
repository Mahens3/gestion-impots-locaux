<?php

namespace App\Http\Controllers;
use App\connectivity;
use Illuminate\Http\Request; 
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\DB;   
use Illuminate\Support\Facades\Storage;

class ConnectivityController extends Controller
{
    public function login(Request $request){
        $result = DB::table("agent")->where("phone", $request->phone)->get();
        if(count($result)>0){
            $result = DB::table("agent")->where("phone", $request->phone)->where("mdp", $request->mdp)->get();
            if(count($result)>0){
                return [
                    "authentificated" => true
                ];
            }
            else{
                return [
                    "phone" => true,
                    "mdp" => false,
                    "authentificated" => false
                ];
            }
        }
        else {
            return [
                "phone" => false,
                "authentificated" => false
            ];
        }
    }

    private function test($value){
        if($value==null){
            return "0000-00-00 00:00:00";
        }
        else{
            return $value;
        }
    }


    public function connectivity(Request $request)
    {
        $propvide = DB::table("construction")->whereNull("numprop")->where("id", $request->phone)->get();
        $ifpbvide = DB::table("construction")->whereNull("numif")->where("id", $request->phone)->get();

        $construction = DB::table("construction")->where("id", $request->phone)->orderBy("datetimes", "desc")->get();
        $dateconstruction = "";
        if(count($construction)>0){
            $dateconstruction = $this->test($construction[0]->datetimes);  
        }
        else{
            $dateconstruction = "0000-00-00 00:00:00";
        }

        $logement = DB::table("logement")->where("id", $request->phone)->orderBy("datetimes", "desc")->get();
        $datelogement = "";
        if(count($logement)>0){
            $datelogement = $this->test($logement[0]->datetimes);  
        }
        else{
            $datelogement = "0000-00-00 00:00:00";
        }

        $ifpb = DB::table("ifpb")->where("id", $request->phone)->orderBy("datetimes", "desc")->get();
        $dateifpb = "";
        if(count($ifpb)>0){
            $dateifpb = $this->test($ifpb[0]->datetimes);  
        }
        else{
            $dateifpb = "0000-00-00 00:00:00";
        }

        $proprietaire = DB::table("proprietaire")->where("id", $request->phone)->orderBy("datetimes", "desc")->get();
        $dateproprietaire = "";
        if(count($proprietaire)>0){
            $dateproprietaire = $this->test($proprietaire[0]->datetimes);  
        }
        else{
            $dateproprietaire = "0000-00-00 00:00:00";
        }

        $personne = DB::table("personne")->where("id", $request->phone)->orderBy("datetimes", "desc")->get();
        $datepersonne = "";
        

        if(count($personne)>0){
            $datepersonne = $this->test($personne[0]->datetimes);  
        }
        else{
            $datepersonne = "0000-00-00 00:00:00";
        }

        return json_encode([
            "connect" => true,
            "construction" => $dateconstruction,
            "logement" => $datelogement,
            "ifpb" => $dateifpb,
            "proprietaire" => $dateproprietaire,
            "personne" => $datepersonne
        ]);        
    }
    // 20 Mars 2023 09:41
    // SELECT a.*, count(c.numcons) as effectif FROM construction c, agent a WHERE a.id=c.idagt AND c.typecons="Imposable" AND surface>0 AND c.numcons not in (SELECT numcons FROM logement) GROUP BY a.nom ORDER BY a.numequip; 
    // +1 amby nbrniv equipe 4, 5, 10
    private function getLog($numcons){
        $result = DB::table("logement")
        ->join("construction",'logement.numcons',"=","construction.numcons")
        ->select('construction.typequart','construction.impot','construction.boriboritany','construction.wc','construction.adress','construction.etatmur','construction.toiture', 'construction.surface', 'construction.nbrniv','construction.access','construction.typehab','logement.*')
        ->where("construction.numcons",$numcons)
        ->get();

        $constru = DB::table("construction")
        ->where("construction.numcons",$numcons)
        ->get();
        return [
            "logements" => $result,
            "construction" => $constru[0]
        ];
    }

    private function toList($array){
        $array = array_map(function($item){
            return (array)$item;
        },$array->toArray());
        return $array;
    }

    private function getParametre(){
        $parametre = [];
        $result = DB::table('parametre')->get();
        $result = $this->toList($result);
        foreach($result as $data){
            $col = $data["colonne"];
            if($col==""){
                $parametre["config"] = $data["coeff"];
            }
            else{
                if(!isset($parametre[$col])){
                    $parametre[$col] = []; 
                }
                $val = $data["valeur"];
                if(!isset($parametre[$col][$val])){
                    $parametre[$col][$val] = [];
                    $parametre[$col][$val] = $data["coeff"];
                }
            }
        }
        return (array)$parametre;
    }

    public function sumPiece($logements){
        $piece = 0;
        foreach($logements as $logement){
            $piece += $logement["nbrpp"] + $logement["nbrps"];
        } 
        return $piece;
    }

    public function taxe($nbr){
        return ($nbr*5)/100;
    }

    public function format($nbr){
        $str = "".$nbr;
        $reste = strlen($nbr)%3;

        $formatted = "";
        for($i=$reste; $i<strlen($str); $i+=3){
            $formatted .= substr($str, $i, 3). " ";
        }
        if($reste>0){
            $formatted = substr($str, 0, $reste)." ". $formatted;
        }

        return trim($formatted);
    }

    public function getimpot($numcons){
        $ifpb = 0;
        $result = $this->getLog($numcons);
        $constru = $result["construction"];
        $logements = $this->toList($result['logements']);
        $colonne = ["typehab","etatmur","access","toiture","typelog"];
        $parametre = $this->getParametre();

        $nbrres = 0;
        $habitation_prop = "non";
        
        if(count($logements)>0){
            // SURFACE DES PIECES (STPP + STPS)
            $sumPiece = $this->sumPiece($logements);

            // SURFACE DES PIECES SI STPP=0
            $surfaceParLog = 0;
            
            $detail=[];

            $array = [];
            $paramPerLog = [];
            $i=0;

            $surf=0;

            $impotpayer = 0;
            foreach($logements as $logement){
                $calcul=0;
                $param = [];
                $sumIFPB = 0;

                if($logement["stpp"]==0){
                    $surfaceParLog = $logements[0]["surface"];
                }

                else{
                    if($constru->nbrniv>1 && count($logements)==1){
                        $surfaceParLog = $constru->nbrniv * $constru->surface;
                    }
                    else{
                        $surfaceParLog = $logement["stpp"];
                    }
                }

                $impotpayer = $logements[0]["impot"];
                // CALCUL SOMME PARAMETRE SAUF LE PARAMERE CONFORT
                foreach($colonne as $col){
                    
                    $value = $logement[$col];
                    if(isset($parametre[$col][$value])){
                        $calcul+=$parametre[$col][$value];
                        $param[$value] = $parametre[$col][$value];
                    }
                }
                // CALCUL SOMME PARAMETRE CONFORT
                $conf = $this->getConfort($parametre["confort"], $logement["confort"], $param);
             
                // CALCUL SOMME PARAMETRE TYPE QUARTIER
                $typequart = $this->getTypequart($parametre["typequart"], $logement["typequart"], $conf["params"]);
                
                // PARAMETRE MINIMUM 
                /**
                if($conf["params"]==0){
                    $typequart["params"] = $parametre["config"];
                    $conf["value"] = $parametre["config"];      
                }
                 */
                
                // CALCUL  = 0; PAR LOGEMENT
                $coeff = $calcul + ($conf["value"]) + ($typequart["value"]);
                
                $calculateImpot = $this->calculateImpot($coeff, $logement, $surfaceParLog);

                // TYPE HABITATION()
                $type = "";
                if($logement["typelog"]=="Habitat"){
                    $type="H";
                }
                else{
                    $type="AU";
                }

                if($logement["typeoccup"]=="Propriétaire"){
                    $habitation_prop="oui";
                    $type.="P";
                }
                else{
                    $type.="T";
                }

                
                $paramPerLog[$i]=[
                    "parametres" => $typequart["params"],
                    "somme coefficient" => ($coeff),
                    "surface par logement" => $surfaceParLog,
                    "valeur locative mensuel" => $this->format(ceil($calculateImpot["valeurLocMensuel"])),
                    "valeur locative annuel" => $this->format(ceil($calculateImpot["valeurLocAnnuel"])),
                    "IFPB par logement" => $this->format(ceil($calculateImpot["valeurLocAnnuel"] * 0.05)),
                    "numlog" => $logement["numlog"],
                    "nbrres" => $logement["nbrres"],
                    "niveau" => $logement["niveau"],
                    "statut" => $logement["statut"],
                    "typelog" => $logement["typelog"],
                    "typeoccup" => $logement["typeoccup"],
                    "vlmeprop" => $logement["vlmeprop"],
                    "vve" => $logement["vve"],
                    "lm" => $logement["lm"],
                    "type" => $type,
                    "vlmeoc" => $logement["vlmeoc"],
                    "confort" => $logement["confort"],
                    "phone" => $logement["phone"],
                    "valrec" => $logement["valrec"],
                    "nbrpp" => $logement["nbrpp"],
                    "stpp" => $logement["stpp"],
                    "nbrps" => $logement["nbrps"],
                    "stps" => $logement["stps"],
                    "impot" => $logement["impot"],
                    "boriboritany" => $logement["boriboritany"],
                    "wc" => $logement["wc"],
                    "numcons" => $logement["numcons"]
                ];
                if($calculateImpot["abattement"]!=0){
                    $sumIFPB+=$calculateImpot["abattement"];
                }
                else{
                    $sumIFPB+=$calculateImpot["valeurLocAnnuel"];
                }
                $array[$i] = $sumIFPB;
                $ifpb+=$sumIFPB;
                
                $i+=1;
            }
            $hetra = $this->somme($array);
            
            $exploded = explode(" ",$hetra);
            $yes = intval(implode("",$exploded));

            return ([
                "logements" => $paramPerLog,
                "ifpb" => $hetra,
                "habprop" => $habitation_prop,
                "nbrres" => $nbrres,
                "ifpb_nbr" => intval(implode("",$exploded)),
                "impot" => $this->format($impotpayer),
            ]);    
        }

        else{
            return ([
                "logements" => [],
                "ifpb" => 0,
                "habprop" => "inconnu",
                "nbrres" => $nbrres,
                "impot" => 0,
            ]);     
        }
        
    }


    // Multiplier par taux
    private function somme($array_sum){
        $sum = 0;
        for($i=0; $i<count($array_sum); $i++){
            $sum += $array_sum[$i] * 0.05;
        }
        return $this->format(ceil($sum));
    }

    private function calculateImpot($sumParametre, $logement, $surfaceParLog){
        $valeurLocMensuel= $sumParametre*$surfaceParLog;
        $valeurLocAnnuel = $valeurLocMensuel*12;

        if($logement["typeoccup"]=="Propriétaire"){
            $abattement = $valeurLocAnnuel*0.3;
        }
        else{
            $abattement = 0;
        }
       
        return [
            "valeurLocMensuel"=> $valeurLocMensuel, 
            "valeurLocAnnuel" => $valeurLocAnnuel,
            "abattement" => $abattement
        ];
    }

    private function getConfort($parametre, $confort, $param){ 
        $splitted = explode(", ", $confort);
        $value = 0;
        foreach($splitted as $elt){
            if(isset($parametre[$elt])){

                $value += ($parametre[$elt]);
                $param[$elt] = $parametre[$elt];
            }
        }
        return ["value" => $value, "params" => $param];
    }

    private function getTypequart($parametre, $typequart, $param){
        $splitted = explode(", ", $typequart);
        $value = 0;
        foreach($splitted as $elt){
            if(isset($parametre[$elt])){
                $value += intval($parametre[$elt]);
                $param[$elt] = $parametre[$elt];
            }
        }
        return ["value" => $value, "params" => $param];
    }

    public function setimage(Request $request){ 
        $filename = $request->file("file")->getClientOriginalName();
        $filename = $request->numcons.".".explode(".",$filename)[1];
        if (Storage::disk('local')->exists($filename)) {     
            Storage::disk('local')->delete($filename);   
        }
        $request->file("file")->storeAs("local", $filename);

        DB::table('construction')->where('numcons',$request->numcons)->update([
            'image' => $filename,
        ]);

        return "success";
    }

    private function isNull($value){
        if($value="null"){
            return null;
        }
        else{
            return $value;
        }
    }

    public function remote(Request $request)
    {
        set_time_limit(700000);


        // INSERTION DU PROPRIETAIRE
        $proprietaires = json_decode($request->proprietaires);
        foreach($proprietaires as $proprietaire){
            try{
                DB::table('proprietaire')->insert([
                    'numprop' => $proprietaire->numprop,
                    'nomprop' => $proprietaire->nomprop,
                    'prenomprop' => $proprietaire->prenomprop,
                    'adress' => $proprietaire->adress,
                    'typeprop' => $proprietaire->typeprop,
                    'datetimes' => $proprietaire->datetimes,
                    'id' => $request->phone,
                ]);
            } catch(\Illuminate\Database\QueryException $e){
                $errorCode = $e->errorInfo[1];
                if($errorCode === 1062){
                    
                }
            }  
        }

        // INSERTION DE L'IFPB
        $ifpbs = json_decode($request->ifpbs);
        foreach($ifpbs as $ifpb){
            try{
                DB::table('ifpb')->insert([
                    'numif' => $ifpb->numif,
                    'exon' => $ifpb->exon,
                    'dernanne' => $ifpb->dernanne,
                    'role' => $ifpb->role,
                    'article' => $ifpb->article,
                    'montantins' => $ifpb->montantins,
                    'montantpay' => $ifpb->montantpay,
                    'datetimes' => $ifpb->datetimes,
                    'cause'=> $ifpb->cause,
                    'id' => $request->phone
                ]);
            }catch(\Illuminate\Database\QueryException $e){
                $errorCode = $e->errorInfo[1];
                if($errorCode === 1062){

                }
            }
            
        }

        $reference = [];

        // INSERTION DE LA CONSTRUCTION AVEC IMAGE
        $constructions = json_decode($request->constructions);
        foreach($constructions as $construction){
            $filename = str_replace("_",".",$construction->image);
            $name = str_replace(".","_",$construction->image);
            if($construction->image!=null && $request->file($name)!=null){    
                try{
                    $file = $request->file($name)->storeAs("local",$filename);
                }
                catch(Exception $e){
                    $errorCode = $e->errorInfo[1];
                    if($errorCode === 1062){

                    }
                }
            }
            $idcoord = 0;
            if($construction->idcoord!=null){
                $idcoord = $construction->idcoord;
                DB::table('coordonnees')->where('id',$construction->idcoord)->update([
                    'dateret' => date("Y-m-d h:i"),
                ]);
            }
            else{
                $idcoord = DB::table('coordonnees')->insert([
                    'dateret' => date("Y-m-d h:i"),
                    'lat' => $construction->lat,
                    "lng" => $construction->lng,
                    "idfoko" => $construction->idfoko,
                    'idagt'  => $construction->idagt,
                    'etat'  => 'C',
                ]);
            }

            // STOCKAGE DES numcons
            $reference[strval($construction->id)] = $construction->numcons;
            
            try{
                DB::table('construction')->insert([ 
                    'numcons' => $construction->numcons,
                    'mur' => $construction->mur,
                    'ossature' => $construction->ossature,
                    'adress' => $construction->adress,
                    'toiture' => $construction->toiture,
                    'fondation' => $construction->fondation,
                    'typehab' => $construction->typehab,
                    'etatmur' => $construction->etatmur,
                    'access' => $construction->access,
                    'adress' => $construction->adress,
                    'wc' => $construction->wc,
                    'typecons' => $construction->typecons,
                    'nbrhab' => $construction->nbrhab,
                    'nbrniv' => $construction->nbrniv,
                    'anconst' => $construction->anconst,
                    'nbrcom' => $construction->nbrcom,
                    'nbrbur' => $construction->nbrbur,
                    'nbrprop' => $construction->nbrprop,
                    'idagt' => $construction->idagt,
                    'fktorigin' =>$construction->fktorigin,
                    'idcoord' => $idcoord,
                    'image' => $construction->image,
                    'nbrloc' => $construction->nbrloc,
                    'typequart' => $construction->typequart,
                    'nbrocgrat' => $construction->nbrocgrat,
                    'boriboritany' => $construction->boriboritany,
                    'surface' => $construction->surface,
                    'coord' => $construction->lat.", ".$construction->lng,
                    'datetimes' => $construction->datetimes,
                    'numter' => null,
                    'idfoko' => $construction->idfoko,
                    'numif' => $this->isNull($construction->numifpb),
                    'numprop' => $this->isNull($construction->numprop),
                    'idagt' => $request->phone
                ]);
            }
            catch(\Illuminate\Database\QueryException $e){
                $errorCode = $e->errorInfo[1];
                if($errorCode === 1062){
                    DB::table('construction')->where("numcons", $construction->numcons)->update(
                                [
                                    'adress' => $construction->adress,
                                    'surface' => $construction->surface,
                                    'typecons' => $construction->typecons,
                                ]
                                );
                }
            }
            
        }

    
        // INSERTION DU LOGEMENT
        $logements = json_decode($request->logements);
        foreach($logements as $logement){
            $datalog = [
                    'numlog' => $logement->numlog,
                    'nbrres' => $logement->nbrres,
                    'niveau' => $logement->niveau,
                    'statut' => $logement->statut,
                    'typelog' => $logement->typelog,
                    'typeoccup' => $logement->typeoccup,
                    'vlmeprop' => $logement->vlmeprop,
                    'lien' => $logement->lien,
                    'nbrpp' => $logement->nbrpp,
                    'nbrps' => $logement->nbrps,
                    'stpp' => $logement->stpp,
                    'stps' => $logement->stps,
                    'vve' => $logement->vve,
                    'lm' => $logement->lm,
                    'lien' => $logement->lien,
                    'declarant' => $logement->declarant,
                    'vlmeoc' => $logement->vlmeoc,
                    'confort' => $logement->confort,
                    'phone' => $logement->phone,
                    'valrec' => $logement->valrec,
                    'datetimes' => $logement->datetimes,
                    'id' => $request->phone
            ];

            // VERIFICATION numcons
            if(isset($logement->numcons)){
                $datalog["numcons"] =  $logement->numcons;
            }else{
                $datalog["numcons"] = $reference[strval($logement->idcons)];
            }


            try{
                DB::table('logement')->insert($datalog);
            }
            catch(\Illuminate\Database\QueryException $e){
                $errorCode = $e->errorInfo[1];
                if($errorCode === 1062){
                }
                else{
                    $error = "yours";
                }

            }
        }

        $personnes = json_decode($request->personnes);
        foreach($personnes as $personne){
            $datapers = [
                    "numpers" =>  $personne->numpers, 
                    'sexe' => $personne->sexe,
                    'age' => $personne->age,
                    'profession' => $personne->profession,
                    'lieu' => $personne->lieu,
                    'datetimes' => $personne->datetimes,  
                    'id' => $request->phone
            ];
                        // VERIFICATION numcons
            if(isset($personne->numcons)){
                $datapers["numcons"] =  $personne->numcons;
            }else
            {
                $datapers["numcons"] = $reference[strval($personne->idcons)];
            }

            try{
                DB::table('personne')->insert($datapers);
            }
            catch(\Illuminate\Database\QueryException $e){
                $errorCode = $e->errorInfo[1];
                if($errorCode === 1062){
                }
            }
        }
        return "successfully";
    }
    
    public function image($filename)
    {
        $path =  storage_path('/uploads/local/'.$filename);
        if(!File::exists($path)){
            abort(404);
        }
        $file = File::get($path);
        $type = File::mimeType($path);
        return response()->make($file, 200)->header("Content-Type", $type);
    }

    public function appgeo()
    {
        $path =  storage_path("/uploads/geohetra.apk");
        if(!File::exists($path)){
            abort(404);
        }
        $file = File::get($path);
        $type = File::mimeType($path);
        return response()->make($file, 200)->header("Content-Type", "application/vnd.android.package-archive");
    }

    public function getlist(){
        $result = DB::table("construction")
        ->join("proprietaire",'construction.numprop',"=","proprietaire.numprop")
        ->join("ifpb",'construction.numif',"=","ifpb.numif")
        ->select('ifpb.role',"ifpb.article",'construction.numcons',DB::raw("concat(proprietaire.nomprop, ' ', proprietaire.prenomprop) as proprietaire"))
        ->get();

        $result = $this->toList($result);
        for($i=0; $i<count($result); $i++){
            $val = $this->getimpot($result[$i]["numcons"]);
            $result[$i]["impot"] = $val["ifpb"];
        }

        return $result;
    }

    public function completeData(){
        $this->completeProprietaire();
        $this->completeIFPB();
    }

    private function completeProprietaire(){
        $agent = DB::table("agent")->where("type","simple")->get();
        foreach($agent as $agt){
            $construction = DB::table("construction")->whereNull("numprop")->where("idagt",$agt->id)->where("typecons","Imposable")->orderBy("datetimes","asc")->get();
            $proprietaire = DB::table("proprietaire")
            ->whereNotIn("numprop",function($q1){
                $q1->select("numprop")->from("construction");
            })->where("id",$agt->phone)->orderBy("datetimes","asc")->get();
            
            $id = 0;
            $count = 0;
            for($i=0; $i<count($construction)-1; $i++){
                $enc = $this->encadrement($construction[$i], $construction[$i+1], $proprietaire, $id);
                if($enc["find"]==true){
                    DB::table('construction')->where('numcons',$construction[$i]->numcons)->update([
                        'numprop' => $proprietaire[$id]->numprop,        
                    ]);     
                } 
                $id = $enc["id"];
            }
        }        
    }

    private function completeIFPB(){
        $agent = DB::table("agent")->where("type","simple")->get();
        foreach($agent as $agt){
            $construction = DB::table("construction")->whereNull("numif")->where("idagt",$agt->id)->where("typecons","Imposable")->orderBy("datetimes","asc")->get();
            $ifpb = DB::table("ifpb")
            ->whereNotIn("numif",function($q1){
                $q1->select("numif")->from("construction");
            })->where("id",$agt->phone)->orderBy("datetimes","asc")->get();
            $id = 0;
            $count = 0;
            for($i=0; $i<count($construction)-1; $i++){
                $enc = $this->encadrement($construction[$i], $construction[$i+1], $ifpb, $id);
                if($enc["find"]==true){
                    DB::table('construction')->where('numcons',$construction[$i]->numcons)->update([
                        'numif' => $ifpb[$id]->numif,        
                    ]);     
                } 
                $id = $enc["id"];
            }
        }        
    }

    private function encadrement($constr1, $constr2, $data, $idprop){
        $value = ["id"=>$idprop, "find" => false];
        for($i=$idprop; $i<count($data); $i++){
            if($constr1->datetimes < $data[$i]->datetimes){
                if($data[$i]->datetimes<$constr2->datetimes){
                    $value = ["id"=>$i+1, "find" => true];
                    break;
                }
                else {
                    $value = ["id"=>$i, "find" => false];
                    break;
                }
            }
            else{
                $value['id'] = $i;
            }
        }
        return $value;
    }
    

    public function detailperfoko($foko){
        $result = DB::table("construction")->where("typecons", "Imposable")->where("idfoko", $foko)->get();
        $array = [];
        for($i=0; $i<count($result); $i++){
            $array[$i] = $this->detail($result[$i]->numcons);
        }
        return $array;
    }

    public function createCsvFile(){
        $foko = DB::table("fokontany")->get();
        for($j=0; $j<count($foko); $j++){
            $result = DB::table("construction")->where("typecons", "Imposable")->where("idfoko", $foko[$j]->id)->get();
            $array = [];
            for($i=0; $i<count($result); $i++){
                $array[$i] = $this->detail($result[$i]->numcons);
                
            }

            $data = $this->getData($array);
            $csv = fopen($foko[$j]->nomfokontany.".csv","w");
            fputs($csv, $bom=(chr(0xEF).chr(0xBB).chr(0xBF)));
            foreach($data as $row){
                fputcsv($csv, $row);
            }
            fclose($csv);
        }
        
    }

    public function badoda($data){
        if(isset($data->ifpb_nbr)){
            return $data->ifpb_nbr;
        }
        else {
            return 0;
        }
    }

    public function getData($array){
        $response = [["n°","id","surface","impot","mur","etatmur","ossature","toiture","fondation","typehab","nom_proprietaire","prenom_proprietaire","idprop","article","role","idifpb","habprop","nbrres","nbr_personne"]];
        for($i=1; $i<count($array); $i++){
            //dd($array[$i]);
            $principal = json_decode($array[$i]);
            $construction = $principal->construction;
            $proprietaire = json_decode($principal->proprietaire);
            $ifpb = json_decode($principal->ifpb);
            $impot = json_decode($principal->impot);
            // dd($impot);
            $response[$i] = [
                $i,
                strval($construction->numcons),
                $construction->surface,
                $this->badoda($impot),
                $construction->mur,
                $construction->etatmur,
                $construction->ossature,
                $construction->toiture,
                $construction->fondation,
                $construction->typehab,

            ];

            if(isset($proprietaire->nomprop)){
                $response[$i][10] = $proprietaire->nomprop;
                $response[$i][11] = $proprietaire->prenomprop;
                $response[$i][12] = $proprietaire->numprop;
            }
            else{
                $response[$i][10] = "";
                $response[$i][11] = "";
                $response[$i][12] = "";
            }

            if(isset($ifpb->article)){
                $response[$i][13] = $ifpb->article;
                $response[$i][14] = $ifpb->role;
                $response[$i][15] = $ifpb->numif;
            }
            else{
                $response[$i][13] = "";
                $response[$i][14] = "";
                $response[$i][15] = "";
            }

/** 
            "habprop" => "inconnu",
            "nbrres" => $nbrres,
            */
            $response[$i][16] = $impot->habprop;
            $response[$i][17] = $impot->nbrres;
            $response[$i][18] = $principal->nombre_personne;
        }

        return $response;
    }

    public function totalfoko(){
        $foko = DB::table("fokontany")->get();
        $details = [];
        $somme = 0;
        $total = 0;
        $totalResult = 0;
        for($i=0; $i<count($foko); $i++){
            $response = $this->detailperfoko($foko[$i]->id);
            $total += count($response);
            
            $allConstruction = DB::table("construction")->where("idfoko", $foko[$i]->id)->get();
            $totalResult+=count($allConstruction);

            $s = $this->sommePerFoko($response);
            $details[$foko[$i]->nomfokontany] = ["montant" => $this->format($s), "nombre" => strval(count($response)) . "/".strval(count($allConstruction))];
            $somme+=$s;

        }
        $details["somme"] = ["total_montant" => $this->format($somme), "total_nombre" => strval($total)."/".strval($totalResult)];
        return $details;
    }

    public function sommePerFoko($result){
        $sum = 0;
        for($i=0; $i<count($result); $i++){
            $json=json_decode($result[$i]);
            $ju = json_decode($json->impot);
            if(isset($ju->ifpb_nbr)){
                $sum+=$ju->ifpb_nbr;
            }
            else{
                $sum+=0;
            }
        }
        return $sum;
    }

    public function detail($numcons){
        $result = DB::table("construction")->where("numcons", $numcons)->get(); 
        $personnes = DB::table("personne")->where("numcons", $numcons)->get(); 

        if(count($result)>0){
            $construction =  $result[0];

            // PROPRIETAIRE
            if($construction->numprop==null){
                $proprietaire = json_encode(["empty" => ""]);
            }
            else{
                $proprietaire =  $this->get("proprietaire", "numprop", $construction->numprop, false);
            }

            // IFPB
            if($construction->numif==null){
                $ifpb = json_encode(["empty" => ""]);
            }
            else{
                $ifpb = $this->get("ifpb", "numif", $construction->numif, false);
            }

            $logement = $this->get("logement", "numcons", $numcons, true);

            return json_encode([
                "construction" => $construction,
                "proprietaire" => $proprietaire,
                "ifpb" => $ifpb,
                "nombre_personne" => count($personnes),
                "logement" => $logement,
                "impot" => json_encode($this->getimpot($numcons))
            ]);
        }
        else{
            return "{}";
        }
    }

    // DAMA numcons = 20230310142427186603403
    // Mme Adjoint numcons =  20230322124926483103407
    // Simulant, vr fighter, asterix et obelix, invitation to a murder
    public function fetch(){
        $this->completeData();
        $nullprop = DB::table("construction")
        ->select('construction.coord','construction.numif','construction.checked','construction.impot', 'construction.idfoko', 'construction.idagt', 'construction.numcons',DB::raw("'' as proprietaire"))
        ->where("construction.idfoko",16)
        ->orWhere("construction.idfoko",14)
        ->whereNull("construction.numprop")
        ->orderBy("idfoko");
        
        $result = DB::table("construction")
        ->join("proprietaire",'construction.numprop',"=","proprietaire.numprop")
        ->select('construction.coord','construction.impot','construction.checked','construction.numif','construction.idfoko', 'construction.idagt', 'construction.numcons',DB::raw("concat(proprietaire.nomprop, ' ', proprietaire.prenomprop) as proprietaire"))

        ->orWhere("construction.idfoko",16)
        ->where("construction.idfoko",14)
        ->unionAll($nullprop)
        ->orderBy("idfoko")
        ->get();

        return json_encode($result);
    }

    private function get($table, $id, $value, $multiple){
        $result = DB::table($table)->where($id, $value)->get();
        if($multiple==true){
            return json_encode($result);
        }
        else{
            if(count($result)>0){
                return json_encode($result[0]);
            }
            else{
                return "{}";
            }
        }
    }
}
