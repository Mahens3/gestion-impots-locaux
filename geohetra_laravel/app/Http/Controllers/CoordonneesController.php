<?php

namespace App\Http\Controllers;

use App\construction;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

class CoordonneesController extends Controller
{
    public function index()
    {
        $centrecoord = DB::table("coordonnees")
            ->join("fokontany", "coordonnees.idfoko", "=", 'fokontany.id')
            ->select('fokontany.nomfokontany', DB::raw("count(coordonnees.idfoko) as effectif"))
            ->groupBy('fokontany.nomfokontany')->where("coordonnees.typequart", "Centre ville")->get();

        $percoord = DB::table("coordonnees")
            ->join("fokontany", "coordonnees.idfoko", "=", 'fokontany.id')
            ->select('fokontany.nomfokontany', DB::raw("count(coordonnees.idfoko) as effectif"))
            ->groupBy('fokontany.nomfokontany')->where("coordonnees.typequart", "Periphérie")->get();

        $centre = [];
        $peripherie = [];

        $nbr = 0;
        for ($i = 0; $i < count($centrecoord); $i++) {
            $nbr += $centrecoord[$i]->effectif;
            $centre[$centrecoord[$i]->nomfokontany] = [$centrecoord[$i]->effectif, $this->calcul($centrecoord[$i]->effectif)];
        }

        echo $nbr;
        $nbr = 0;
        for ($i = 0; $i < count($percoord); $i++) {
            $nbr += $percoord[$i]->effectif;
            $peripherie[$percoord[$i]->nomfokontany] = [$percoord[$i]->effectif, $this->calcul($percoord[$i]->effectif)];
        }

        echo "<br/>";
        echo "<br/>";
        echo $nbr;
        echo "<br/>";
        echo "<br/>";
        echo json_encode($peripherie);
        echo "<br/>";
        echo "<br/>";

        echo json_encode($centre);
    }

    private function calcul($nbr)
    {
        $result = round($nbr / 220);
        return $result;
    }

    public function partage()
    {

        $group = [
            [
                ["idfoko" => 1, "idagt" => 2],
                ["idfoko" => 4, "idagt" => 4],
                ["idfoko" => 15, "idagt" => 3],
                ["idfoko" => 16, "idagt" => 1]
            ],
            [
                ["idfoko" => 5, "idagt" => 3],
                ["idfoko" => 2,  "idagt" => 4],
                ["idfoko" => 11,  "idagt" => 3],
            ],
            [
                ["idfoko" => 9, "idagt" => 3],
                ["idfoko" => 3, "idagt" => 2],
                ["idfoko" => 6, "idagt" => 1],
                ["idfoko" => 13, "idagt" => 4]
            ],
            [
                ["idfoko" =>  8, "idagt" => 1],
                ["idfoko" =>  7, "idagt" => 1],
                ["idfoko" =>  10, "idagt" => 1],
                ["idfoko" =>  18, "idagt" => 7]
            ],
            [
                ["idfoko" =>  19, "idagt" => 1],
                ["idfoko" =>  12, "idagt" =>  2],
                ["idfoko" =>  14, "idagt" => 2],
                ["idfoko" =>  21, "idagt" => 1],
                ["idfoko" =>  20, "idagt" => 3]
            ]
        ];

        $equip = [];

        for ($i = 0; $i < count($group); $i++) {
            $num_equip = 0;
            for ($j = 0; $j < count($group[$i]); $j++) {
                for ($k = 0; $k < $group[$i][$j]["idfoko"]; $k++) {
                    // Assuming $start = 0 and $end = 1 for each iteration, adjust as needed
                    $this->affect($group[$i][$j]["idagt"], $group[$i][$j]["idfoko"], 0, 1);
                    $num_equip += 1;
                }
            }
        }

        // Define $result, for example, return the number of groups processed
        $result = count($group);
        return $result;
    }

    private function affect($num_equip, $idfoko, $start, $end)
    {
        $coord = DB::table("coordonnees")->where("coordonnees.idfoko", $idfoko)->get();
        for ($i = $start; $i < $end; $i++) {
            $this->update($num_equip, $coord[$i]->id);
        }
    }

    private function update($num_equip, $id)
    {
        DB::table('coordonnees')->where('id', $id)->update([
            'idagt' => $num_equip,
        ]);
    }

    public function part()
    {
        $agents = $this->getagent();

        $coord = DB::table("coordonnees")
            ->select("coordonnees.id", "fokontany.rang")
            ->orderBy("rang", "asc")
            ->join("fokontany", 'fokontany.id', "=", "coordonnees.idfoko")->get();

        $reste = count($coord) % 200;
        $tour = (count($coord) - $reste) / 200;

        $id = 0;
        $fin = 0;

        for ($i = 0; $i < $tour; $i++) {
            for ($j = $i * 200; $j < ($i + 1) * 200; $j++) {
                DB::table('coordonnees')->where('id', $coord[$j]->id)->update([
                    'idagt' => $agents[$id],
                ]);
            }
            if ($id < 9) {
                $id += 1;
            } else {
                $id = 0;
                $agents = $this->inverse($agents);
            }
            $fin = ($i + 1) * 200;
        }

        $tour = ($reste - ($reste % 10)) / 10;
        $reste = $reste % 10;

        for ($i = 0; $i < $tour; $i++) {
            for ($j = $fin; $j < $fin + 10; $j++) {
                DB::table('coordonnees')->where('id', $coord[$j]->id)->update([
                    'idagt' => $agents[$id],
                ]);
            }
            if ($id < 9) {
                $id += 1;
            } else {
                $id = 0;
                $agents = $this->inverse($agents);
            }
            $fin = $fin + 10;
        }

        $id = 0;
        for ($j = $fin; $j < $fin + $reste; $j++) {
            DB::table('coordonnees')->where('id', $coord[$j]->id)->update([
                'idagt' => $agents[$id],
            ]);
            $id += 1;
        }

        return $tour;
    }

    public function getagent()
    {
        $agents = DB::table("agent")
            ->select('agent.id')->where("agent.type", "simple")->orderBy("id", "asc")->get();
        for ($i = 0; $i < count($agents); $i++) {
            $agents[$i] = $agents[$i]->id;
        }
        return $agents;
    }

    // public function getcoord(Request $request){

    //     $coord = DB::table("coordonnees")
    //     ->join("fokontany","coordonnees.idfoko","=",'fokontany.id')
    //     ->whereNull("coordonnees.dateret")
    //     ->whereNull("coordonnees.etat")
    //     ->select('fokontany.rang',"coordonnees.*");

    //     if(intval($request->idcoord)>0){
    //         $coord = $coord->where("coordonnees.idagt",$request->idagt)
    //         ->where("coordonnees.id",">", $request->idcoord)->get();
    //     }
    //     else{    
    //         $coord = $coord->where("coordonnees.idagt",$request->idagt)->get();
    //     }
    //     //SELECT a.*, count(c.numcons) as effectif FROM construction c, agent a WHERE a.id=c.idagt AND c.typecons="Imposable" AND surface>0 AND c.numcons not in (SELECT numcons FROM logement) GROUP BY a.nom ORDER BY a.numequip; 
    //     /**
    //     $coord = DB::table("construction")
    //     ->where("construction.typecons","Imposable")
    //     ->where("construction.surface",">",1)
    //     ->where("construction.idagt", $request->idagt)
    //     ->whereNotIn("construction.numcons",function($q){
    //         $q->select("numcons")
    //         ->from("logement");
    //     })->get();
    //     */
    //     return $coord;
    // }

    // public function getcoord(Request $request)
    // {
    //     // 📌 Log des paramètres reçus
    //     Log::info('📩 Requête getcoord reçue', [
    //         'idagt' => $request->idagt ?? $request->json('idagt'),
    //         'idcoord' => $request->idcoord ?? $request->json('idcoord'),
    //     ]);

    //     $coord = DB::table("coordonnees")
    //         ->join("fokontany", "coordonnees.idfoko", "=", 'fokontany.id')
    //         ->whereNull("coordonnees.dateret")
    //         ->whereNull("coordonnees.etat")
    //         ->select('fokontany.rang', "coordonnees.*");

    //     if (intval($request->idcoord ?? $request->json('idcoord')) > 0) {
    //         $coord = $coord->where("coordonnees.idagt", $request->idagt ?? $request->json('idagt'))
    //             ->where("coordonnees.id", ">", $request->idcoord ?? $request->json('idcoord'))
    //             ->get();
    //     } else {
    //         $coord = $coord->where("coordonnees.idagt", $request->idagt ?? $request->json('idagt'))->get();
    //     }

    //     // ✅ Nettoyage des valeurs NULL côté serveur
    //     $cleanCoord = $coord->map(function ($item) {
    //         return [
    //             'id' => $item->id ?? 0,
    //             'lat' => $item->lat ?? 0.0,
    //             'lng' => $item->lng ?? 0.0,
    //             'idagt' => $item->idagt ?? 0,
    //             'typequart' => $item->typequart ?? '',
    //             'rang' => $item->rang ?? 0,
    //             'idfoko' => $item->idfoko ?? 0,
    //         ];
    //     });

    //     // 📌 Log du résultat formaté
    //     Log::info('✅ Résultat cleanCoord', $cleanCoord->toArray());

    //     return $cleanCoord;
    // }


    public function getcoord(Request $request)
    {
        // 📌 Log des paramètres reçus
        Log::info('📩 Requête getcoord reçue', [
            'idagt' => $request->idagt ?? $request->json('idagt'),
            'idcoord' => $request->idcoord ?? $request->json('idcoord'),
        ]);

        $coord = DB::table("coordonnees")
            ->join("fokontany", "coordonnees.idfoko", "=", 'fokontany.id')
            ->whereNull("coordonnees.dateret")
            ->whereNull("coordonnees.etat")
            ->select('fokontany.rang', "coordonnees.*");

        if (intval($request->idcoord ?? $request->json('idcoord')) > 0) {
            $coord = $coord->where("coordonnees.idagt", $request->idagt ?? $request->json('idagt'))
                ->where("coordonnees.id", ">", $request->idcoord ?? $request->json('idcoord'))
                ->get();
        } else {
            $coord = $coord->where("coordonnees.idagt", $request->idagt ?? $request->json('idagt'))->get();
        }

        // ✅ Nettoyage des valeurs NULL côté serveur
        $cleanCoord = $coord->map(function ($item) {
            return [
                'id' => $item->id ?? 0,
                'lat' => $item->lat ?? 0.0,
                'lng' => $item->lng ?? 0.0,
                'idagt' => $item->idagt ?? 0,
                'typequart' => $item->typequart ?? '',
                'rang' => $item->rang ?? 0,
                'idfoko' => $item->idfoko ?? 0,
            ];
        });

        // 📌 Log du résultat
        Log::info('✅ Résultat cleanCoord', $cleanCoord->toArray());

        // 🚀 Retourne proprement un JSON avec statut 200
        return response()->json([
            'success' => true,
            'count' => $cleanCoord->count(),
            'data' => $cleanCoord
        ], 200);
    }


    public function inverse($agents)
    {
        $agts = [];
        $id = 0;
        for ($i = count($agents) - 1; $i > -1; $i--) {
            $agts[$id] = $agents[$i];
            $id += 1;
        }
        return $agts;
    }
}
