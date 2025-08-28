<?php

namespace App\Http\Controllers;
use App\logement;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class LogementController extends Controller
{
    public function index()
    {
        $logement = DB::table('logement')->get();
        return view('logement', compact('logement'));
       // return json_encode($logement);
    }
    public function store(Request $request)
    {
        DB::table('logement')->insert([
            'numlog' => $request->numlog,
            'nbrres' => $request->nbrres,
            'niveau' => $request->niveau,
            'statut' => $request->statut,
            'typelog' => $request->typelog,
            'typeoccup' => $request->typeoccup,
            'vlmeprop' => $request->vlmeprop,
            'vve' => $request->vve,
            'lm' => $request->lm,
            'vlmeoc' => $request->vlmeoc,
            'confort' => $request->confort,
            'valrec' => $request->valrec,
            'nbrpp' => $request->nbrpp,
            'stpp' => $request->stpp,
            'nbrps' => $request->nbrps,
            'stps' => $request->stps,
            'declarant' => $request->declarant,
            'lien' => $request->lien,
            'forCalcul' => 1,
            'datetimes' => $request->datetimes,
            'numcons' => $request->numcons,
        ]);
        return json_encode('ajout avec succes'); 
    }

    public function update(Request $request)
    {
        DB::table('logement')->where('numlog',$request->numlog)->update([
            'nbrres' => $request->nbrres,
            'niveau' => $request->niveau,
            'statut' => $request->statut,
            'typelog' => $request->typelog,
            'typeoccup' => $request->typeoccup,
            'vlmeprop' => $request->vlmeprop,
            'vve' => $request->vve,
            'lm' => $request->lm,
            'vlmeoc' => $request->vlmeoc,
            'confort' => $request->confort,
            'declarant' => $request->declarant,
            'lien' => $request->lien,
            'phone' => $request->phone,
            'valrec' => $request->valrec,
            'nbrpp' => $request->nbrpp,
            'stpp' => $request->stpp,
            'nbrps' => $request->nbrps,
            'stps' => $request->stps,
            'datetimes' => $request->datetimes
        ]);
        
         return json_encode('modification avec succes');
    }

    public function updatemultiple(Request $request)
    {
        // echo $request->ossature;
        $data = $request->data;
        foreach($data as $log){
            DB::table('logement')->where('numCons',$log["numcons"])->update([
                'nbrres' => $log["nbrres"],
                'niveau' => $log["niveau"],
                'statut' => $log["statut"],
                'typelog' => $log["typelog"],
                'typeoccup' => $log["typeoccup"],
                'vlmeprop' => $log["vlmeprop"],
                'vve' => $log["vve"],
                'lm' => $log["lm"],
                'vlmeoc' => $log["vlmeoc"],
                'confort' => $log["confort"],
                'phone' => $log["phone"],
                'valrec' => $log["valrec"],
                'nbrpp' => $log["nbrpp"],
                'stpp' => $log["stpp"],
                'nbrps' => $log["nbrps"],
                'stps' => $log["stps"],
                'datetimes' => $log["datetimes"],
                'numCons' => $log["numCons"],
            ]);    
        }
         return json_encode('modification avec ssuccès'); 

    }

    public function destroy($id)
    {
        DB::table('logement')->where('numlog',$id)->delete();

         return json_encode('supprimer avec succes');
    }

}
