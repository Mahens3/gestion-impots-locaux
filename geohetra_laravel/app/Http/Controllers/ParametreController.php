<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;


class ParametreController extends Controller
{
    public function index()
    {
        $parametre = DB::table('parametre')->get();
        return response()->json($parametre);
    }

    public function store(Request $request)
    {
        DB::table('parametre')->insert([
            'entity' => $request->entity,
            'designation' => $request->designation,
            'colonne' => $request->colonne,
            'valeur' => $request->valeur,
            'coeff' => $request->coeff
        ]);    
        return json_encode('ajout avec succes'); 
    }  

    public function update(Request $request)
    {
        DB::table('parametre')->where('id',$request->id)->update([
            'entity' => $request->entity,
            'designation' => $request->designation,
            'colonne' => $request->colonne,
            'valeur' => $request->valeur,
            'coeff' => $request->coeff
        ]);

         return json_encode('mial');

    }

    public function destroy($id)
    {
        DB::table('parametre')->where('id',$id)->delete();

         return json_encode('supprimer avec succes');
    }


}
