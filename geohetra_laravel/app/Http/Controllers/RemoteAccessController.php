<?php

namespace App\Http\Controllers;

use App\Models\Construction;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RemoteAccessController extends Controller
{

    private function getProprietaire($proprietaire)
    {
        if ($proprietaire != null) {
            $data = [
                'numprop' => $proprietaire->numprop,
                'nomprop' => $proprietaire->nomprop,
                'prenomprop' => $proprietaire->prenomprop,
                'adress' => $proprietaire->adress,
                'created_at' => $proprietaire->created_at,
                'updated_at' => $proprietaire->updated_at,
            ];

            try {
                DB::table('proprietaire')->insert($data);
            } catch (\Illuminate\Database\QueryException $e) {
                $errorCode = $e->errorInfo[1];
                if ($errorCode === 1062) {
                    DB::table('proprietaire')->where('numprop', $proprietaire->numprop)->update($data);
                }
            }
            return $proprietaire->numprop;
        } else {
            return null;
        }
    }

    private function getSynchronisation()
    {
        $created = DB::table('construction')->orderBy('created_at', 'DESC')->limit(1)->get();
        $updated = DB::table('construction')->orderBy('updated_at', 'DESC')->limit(1)->get();

        return [
            'created' => count($created) > 0 ? $created[0]->created_at : null,
            'updated' => count($updated) > 0 ? $updated[0]->updated_at : null,
        ];
    }

    private function setLogements($logements, $numcons)
    {
        foreach ($logements as $logement) {
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
                'created_at' => $logement->created_at,
                'updated_at' => $logement->updated_at,
            ];

            try {
                DB::table('logement')->insert($datalog);
            } catch (\Illuminate\Database\QueryException $e) {
                $errorCode = $e->errorInfo[1];
                if ($errorCode === 1062) {
                    DB::table('logement')->where('numlog', $logement->numlog)->update($datalog);
                }
            }
        }
    }

    public function getFilename($file)
    {
        $splitted = explode(".", $file);
        return $splitted[count($splitted) - 1];
    }
    public function upload(Request $request)
    {
        set_time_limit(9999999999);

        $phone = $request->phone;
        Log::info("📱 Envoi des données pour : $phone");

        $constructions = json_decode($request->constructions);

        // Vérifier l'agent
        $result = DB::table("agent")
            ->where("phone", $request->phone)
            ->where("mdp", $request->mdp)
            ->get();

        if (count($result) === 0) {
            Log::warning("Agent non trouvé pour le téléphone : $phone");
            return ["user" => false];
        }

        $agentId = $result[0]->id;
        Log::info("Agent trouvé : ID $agentId");

        foreach ($constructions as $construction) {

            // Gestion sécurisée de l'image
            $filename = property_exists($construction, 'image') && $construction->image != null
                ? $this->getFilename($construction->image)
                : null;

            try {
                if ($filename && $request->file($construction->numcons) != null) {
                    $image = $request->file($construction->numcons);
                    $construction->image = $construction->numcons . "." . $filename;
                    $image->move(public_path('images'), $construction->numcons . "." . $filename);
                    Log::info("Image uploadée pour la construction " . $construction->numcons);
                }
            } catch (Exception $e) {
                Log::error("Erreur upload image pour " . $construction->numcons . " : " . $e->getMessage());
            }

            // Préparer les données en sécurisant chaque propriété
            $data = [
                'numcons' => $construction->numcons ?? '',
                'mur' => $construction->mur ?? '',
                'ossature' => $construction->ossature ?? '',
                'adress' => $construction->adress ?? '',
                'toiture' => $construction->toiture ?? '',
                'fondation' => $construction->fondation ?? '',
                'typehab' => $construction->typehab ?? '',
                'etatmur' => $construction->etatmur ?? '',
                'access' => $construction->access ?? '',
                'wc' => $construction->wc ?? '',
                'typecons' => $construction->typecons ?? '',
                'nbrniv' => $construction->nbrniv ?? 0,
                'anconst' => $construction->anconst ?? null,
                'idagt' => $agentId,
                'image' => $construction->image ?? null,
                'typequart' => $construction->typequart ?? '',
                'boriboritany' => $construction->boriboritany ?? '',
                'surface' => $construction->surface ?? 0,
                'coord' => (isset($construction->lat) && isset($construction->lng)) ? $construction->lat . ', ' . $construction->lng : '',
                'idfoko' => $construction->idfoko ?? null,
                'article' => $construction->article ?? null,
                'created_at' => $construction->created_at ?? now(),
                'updated_at' => $construction->updated_at ?? now(),
                'numprop' => $this->getProprietaire($construction->proprietaire ?? null),
            ];

            // Insertion / mise à jour
            try {
                DB::table('construction')->insert($data);
                Log::info("Construction insérée : " . $construction->numcons);
            } catch (\Illuminate\Database\QueryException $e) {
                $errorCode = $e->errorInfo[1];
                if ($errorCode === 1062) { // Duplicate entry
                    DB::table('construction')->where('numcons', $construction->numcons)->update($data);
                    Log::info("Construction mise à jour : " . $construction->numcons);
                } else {
                    Log::error("Erreur DB pour " . $construction->numcons . " : " . $e->getMessage());
                }
            }

            // Gestion sécurisée des logements
            try {
                $logements = property_exists($construction, 'logements') && is_array($construction->logements)
                    ? $construction->logements
                    : [];
                $this->setLogements($logements, $construction->numcons);
                Log::info("Logements traités pour " . $construction->numcons);
            } catch (Exception $e) {
                Log::error("Erreur traitement logements pour " . $construction->numcons . " : " . $e->getMessage());
            }
        }

        Log::info("✅ Upload terminé pour l'agent ID $agentId");

        return $this->getSynchronisation();
    }



    public function download(Request $request)
    {

        $agent = DB::table('agent')->where('phone', $request->phone)
            ->where('mdp', $request->mdp)->get();

        if (count($agent) > 0) {
            $constructions = Construction::where('created_at', '>', $request->created)
                ->where('id', $request->phone)
                ->whereNull("etatmur")->whereNull("ossature")->whereNull("fondation")->whereNull("mur")->whereNull("toiture")
                ->whereNull("typecons")
                ->limit(20)
                ->orderBy('created_at', 'ASC')->get();
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
