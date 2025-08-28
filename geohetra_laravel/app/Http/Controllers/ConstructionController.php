<?php

namespace App\Http\Controllers;
use App\Models\Construction;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

class ConstructionController extends Controller
{
    public function index()
    {
        $construction = DB::table('construction')->get();
        return json_encode($construction);
    }  

    public function addImage(Request $request){
        if ($request->hasFile('image' )) {
            $image = $request->file("image");
            $filename = $this->getFilename($image, $request->numcons);
            try {
                $image->move( public_path( 'images' ), $filename);
                $image = $filename;
            } catch( Exception $e ) {
                $errorCode = $e->errorInfo[ 1 ];
                if ( $errorCode === 1062 ) {
                }
            }
        }

        Construction::where("numcons", $request->numcons)->update( [
            'image' => $image
        ]);

    }
   
    public function store(Request $request)
    {
        Construction::create([ 
            'numcons' =>  $request->numcons,
            'mur' => $request->mur,
            'ossature' => $request->ossature,
            'idfoko' => $request->idfoko,
            'toiture' => $request->toiture,
            'fondation' => $request->fondation,
            'typehab' => $request->typehab,
            'etatmur' => $request->etatmur,
            'access' => $request->access,
            'article' => $request->article,
            'idfoko' => $request->idfoko,
            'nbrniv' => $request->nbrniv,
            'anconst' => $request->anconst,
            'typequart' => $request->typequart,
            'surface' => $request->surface,
            'boriboritany' => $request->boriboritany,
            'geometry' => $request->geometry,
            'adress' => $request->adress,
            'newarticle' => $this->getNumarticle() + 1,
            'numfiche' => $this->getNumfiche() + 1,
            'coord' => $request->coord,
        ]);

        return "success";    
    }

    private function getFilename($image, $numcons) {
        $filename = $image->getClientOriginalName();
        return $numcons.".".explode(".",$filename)[1];
    }

    private function getNumfiche(){
        $result = Construction::where("typecons", "Imposable")
        ->orderBy("numfiche", "DESC")->limit(1)->get();

        return $result[0]->numfiche;
    }

    private function getNumarticle(){
        $result = Construction::where("typecons", "Imposable")
        ->orderBy("newarticle", "DESC")->limit(1)->get();

        return $result[0]->newarticle;
    }

    public function update(Request $request)
    {
        $image = null;
        $construction = json_decode( $request->data );
       
        $data = DB::table('construction')->where("numcons", $construction->numcons)->get();
        $image = $data[0]->image;

        
        if ($request->hasFile('image' )) {
            $image = $request->file("image");
            $filename = $this->getFilename($image, $construction->numcons);
            try {
                $image->move( public_path( 'images' ), $filename);
                $image = $filename;
            } catch( Exception $e ) {
                $errorCode = $e->errorInfo[ 1 ];
                if ( $errorCode === 1062 ) {
                }
            }
        }

        Construction::where("numcons", $construction->numcons)->update( [
            'mur' => $construction->mur,
            'ossature' => $construction->ossature,
            'idfoko' => $construction->idfoko,
            'toiture' => $construction->toiture,
            'fondation' => $construction->fondation,
            'typehab' => $construction->typehab,
            'etatmur' => $construction->etatmur,
            'access' => $construction->access,
            'article' => $construction->article,
            'nbrniv' => $construction->nbrniv,
            'anconst' => $construction->anconst,
            'typequart' => $construction->typequart,
            'surface' => $construction->surface,
            'idfoko' => $construction->idfoko,
            'geometry' => $construction->geometry,
            'boriboritany' => $construction->boriboritany,
            'adress' => $construction->adress,
            'coord' => $construction->coord,
            'image' => $image
        ] );

        return 'success';
        
    } 

    public function addMultiple(Request $request) {
        $data = $request->data;
        for($i=0; $i<count($data); $i++){
            try{
                Construction::create([
                    "numcons" => $data[$i]["numcons"],
                    "idfoko" => $data[$i]["idfoko"],
                    "idagt" => $data[$i]["idagt"],
                    "coord" => $data[$i]["coord"],
                    "geometry" => $data[$i]["geometry"],
                    "numprop" => $data[$i]["numprop"],
                    "surface" => $data[$i]["surface"],
                ]);
            }catch(\Illuminate\Database\QueryException $e){
                Construction::where("numcons", strval($data[$i]["numcons"]))->update([
                    "idfoko" => $data[$i]["idfoko"],
                    "idagt" => $data[$i]["idagt"],
                    "coord" => $data[$i]["coord"],
                    "geometry" => $data[$i]["geometry"],
                    "surface" => $data[$i]["surface"],
                ]);
            }
        }
        return [
            "status" => true,
            
        ];
    }
    
    public function setprop(Request $request){
        DB::table('construction')->where('numcons',$request->numcons)->update([
            'numprop' => $request->numprop,
        ]);
    }

    public function setifpb(Request $request){
        DB::table('construction')->where('numcons',$request->numcons)->update([
            'numif' => $request->numif,
        ]);
    }


    public function destroy($id)
    {
        DB::table('construction')->where('numCons',$id)->delete();
        return json_encode('supprimer avec succes');
    }


}
