<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class AgentController extends Controller
{
    public function index()
    {
        $agent = DB::table('agent')->select('agent.id',"agent.numequip",'agent.nom','agent.phone','agent.type')->where("agent.type","agent")->get();
        return $agent;
    }  
   
    public function store(Request $request)
    {
        DB::table('agent')->insert([ 
            'nom' =>  $request->nom,
            'mdp' =>  $request->mdp,
            'type' =>  $request->type,
            'phone' =>  $request->phone
        ]);

        return "success";    
    }

    public function update(Request $request)
    {
        DB::table('agent')->where('id',$request->id)->update([
            'nom' =>  $request->nom,
            'mdp' =>  $request->mdp,
            'type' =>  $request->type,
            'phone' =>  $request->phone
        ]);
        return "success updated";
    } 

    public function delete($id)
    {
        DB::table('agent')->where('id',$id)->delete();
        return "success";
    }

}
