<?php

namespace App\Http\Controllers;

use App\Models\Fokontany;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class FokontanyController extends Controller
{  
    public function index()
    {
        $fokontany = DB::table('fokontany')->get();
        return json_encode($fokontany);
    }

    public function store(Request $request)
    {

        DB::table('fokontany')->insert([
            'nomfokontany' =>  $request->nomfokontany
        ]);

        return "success";
    }

    public function update(Request $request)
    {
        DB::table('fokontany')->where('id', $request->id)->update([
            'nomfokontany' => $request->nomfokontany
        ]);
        return "success updated";
    }

    public function delete($id)
    {
        DB::table('fokontany')->where('id', $id)->delete();
        return "success";
    }
}
