<?php

namespace App\Http\Controllers;

use App\Models\Construction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RemoteAccessController extends Controller {

    private function getProprietaire( $proprietaire ) {
        if ( $proprietaire != null ) {
            $data = [
                'numprop' => $proprietaire->numprop,
                'nomprop' => $proprietaire->nomprop,
                'prenomprop' => $proprietaire->prenomprop,
                'adress' => $proprietaire->adress,
                'created_at' => $proprietaire->created_at,
                'updated_at' => $proprietaire->updated_at,
            ];

            try {
                DB::table( 'proprietaire' )->insert( $data );
            } catch( \Illuminate\Database\QueryException $e ) {
                $errorCode = $e->errorInfo[ 1 ];
                if ( $errorCode === 1062 ) {
                    DB::table( 'proprietaire' )->where( 'numprop', $proprietaire->numprop )->update( $data );
                }
            }
            return $proprietaire->numprop;
        } else {
            return null;
        }
    }

    private function getSynchronisation() {
        $created = DB::table( 'construction' )->orderBy( 'created_at', 'DESC' )->limit( 1 )->get();
        $updated = DB::table( 'construction' )->orderBy( 'updated_at', 'DESC' )->limit( 1 )->get();
   
        return [
            'created' => count( $created )>0 ? $created[ 0 ]->created_at : null,
            'updated' => count( $updated )>0 ? $updated[ 0 ]->updated_at : null,
        ];
    }

    private function setLogements( $logements, $numcons ) {
        foreach ( $logements as $logement ) {
            $datalog = [
                'numlog' => $logement->numlog,
                'nbrres' => $logement->nbrres,
                'niveau' => $logement->niveau,
                'statut' => $logement->statut,
                'typelog' => $logement->typelog,
                'typeoccup' => $logement->typeoccup,
                'lien' => $logement->lien,
                'numcons' => $numcons,
                'stps' => $logement->stps,
                'vve' => $logement->vve,
                'lm' => $logement->lm,
                'lien' => $logement->lien,
                'declarant' => $logement->declarant,
                'confort' => $logement->confort,
                'phone' => $logement->phone,
                'created_at' =>$logement->created_at,
                'updated_at' =>$logement->updated_at,
            ];

            try {
                DB::table( 'logement' )->insert( $datalog );
            } catch( \Illuminate\Database\QueryException $e ) {
                $errorCode = $e->errorInfo[ 1 ];
                if ( $errorCode === 1062 ) {
                    DB::table( 'logement' )->where( 'numlog', $logement->numlog )->update( $datalog );
                }
            }
        }
    }

    public function getFilename($file) {
        $splitted = explode(".", $file);
        return $splitted[count($splitted) - 1];
    }

    public function upload( Request $request ) {
        set_time_limit( 9999999999 );
        $phone = $request->phone;
        $constructions = json_decode( $request->constructions );

        $result = DB::table("agent")->where("phone", $request->phone)->where("mdp", $request->mdp)->get();
        if(count($result)> 0) {
            foreach ( $constructions as $construction ) {
                $filename = $this->getFilename($construction->image);
                if ( $construction->image != null && $request->file( $construction->numcons ) != null ) {
                    $image = $request->file( $construction->numcons ) ;
                    $construction->image = $construction->numcons.".".$filename;
                    try {
                        $image->move( public_path( 'images' ), $construction->numcons.".".$filename );
                    } catch( Exception $e ) {
                        $errorCode = $e->errorInfo[ 1 ];
                        if ( $errorCode === 1062 ) {
    
                        }
                    }
                }
    
                $data = [
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
                    'nbrniv' => $construction->nbrniv,
                    'anconst' => $construction->anconst,
                    'idagt' => $construction->idagt,
                    'image' => $construction->image,
                    'typequart' => $construction->typequart,
                    'boriboritany' => $construction->boriboritany,
                    'surface' => $construction->surface,
                    'coord' => $construction->lat.', '.$construction->lng,
                    'idfoko' => $construction->idfoko,
                    'article' => $construction->article,
                    'created_at' =>$construction->created_at,
                    'updated_at' =>$construction->updated_at,
                    'numprop' => $this->getProprietaire( $construction->proprietaire ),
                    'idagt' => $result[0]->id
                ];
                
                try {
                    DB::table( 'construction' )->insert( $data );
                } catch( \Illuminate\Database\QueryException $e ) {
                    $errorCode = $e->errorInfo[ 1 ];
                    if ( $errorCode === 1062 ) {
                        DB::table( 'construction' )->where( 'numcons', $construction->numcons )->update( $data );
                       
                    }
                }
                $this->setLogements( $construction->logements, $construction->numcons );
            }
    
            return $this->getSynchronisation();
        }
        else{
            return [
                "user" => false
            ];
        }

        
    }

    public function download( Request $request ) {

        $agent = DB::table( 'agent' )->where( 'phone', $request->phone )
        ->where( 'mdp', $request->mdp )->get();

        if ( count( $agent )>0 ) {
            $constructions = Construction::where( 'created_at', '>', $request->created )
            ->where('id', $request->phone )
            ->whereNull("etatmur")->whereNull("ossature")->whereNull("fondation")->whereNull("mur")->whereNull("toiture")
            ->whereNull("typecons")
            ->limit(20)
            ->orderBy( 'created_at', 'ASC' )->get();
            return [
                'status' => true,
                'user' => true,
                'created' => $request->created,
                'constructions' => $constructions
            ];
        } else {
            return [
                'status' => false,
                'constructions' => []
            ];
        }
    }
}
