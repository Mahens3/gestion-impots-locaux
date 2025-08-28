<?php

namespace App\Http\Controllers;
use App\proprietaire;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;



class ProprietaireController extends Controller
{
    public function index()
    {
        $proprietaire = DB::table('proprietaire')->get();
        return view('proprietaire', compact('proprietaire'));
       // return json_encode($construction);
    }

    public function store(Request $request)
    {
        DB::table('proprietaire')->insert([
            'numprop' => $request->numprop,
            'nomprop' => $request->nomprop,
            'prenomprop' => $request->prenomprop,
            'propriete' => $request->propriete,
            'adress' => $request->adress,
            'typeprop' => $request->typeprop,
            'datetimes' => $request->datetimes,
        ]);    

        if(isset($request->numcons)){
            DB::table('construction')->where('numcons', $request->numcons)->update([
                'numprop' => $request->numprop,
            ]);
        }
        return json_encode('ajout avec succes'); 
    }  

    public function update(Request $request)
    {
        DB::table('proprietaire')->where('numprop',$request->numprop)->update([
            'numprop' => $request->numprop,
            'nomprop' => $request->nomprop,
            'prenomprop' => $request->prenomprop,
            'propriete' => $request->propriete,
            'adress' => $request->adress,
            'typeprop' => $request->typeprop,
            'datetimes' => $request->datetimes,
        ]);
        
         return json_encode('modification avec succes');
    }
    

    public function destroy($id)
    {
        DB::table('proprietaire')->where('numprop',$id)->delete();
         return json_encode('supprimer avec succes');
    }

}
