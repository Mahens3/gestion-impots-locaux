<?php

namespace App\Http\Controllers;

use App\Models\Construction;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RemoteAccessController extends Controller
{

    /**
     * Insère ou met à jour un propriétaire
     */
    private function getProprietaire($proprietaire)
    {
        if (!$proprietaire) return null;

        $data = [
            'numprop'     => $proprietaire->numprop,
            'nomprop'     => $proprietaire->nomprop,
            'prenomprop'  => $proprietaire->prenomprop,
            'adress'      => $proprietaire->adress,
            'created_at'  => $proprietaire->created_at,
            'updated_at'  => $proprietaire->updated_at,
        ];

        DB::table('proprietaire')->updateOrInsert(
            ['numprop' => $proprietaire->numprop],
            $data
        );

        return $proprietaire->numprop;
    }

    /**
     * Dernière date de sync
     */
    private function getSynchronisation()
    {
        $created = DB::table('construction')
            ->orderByDesc('created_at')
            ->first();

        $updated = DB::table('construction')
            ->orderByDesc('updated_at')
            ->first();

        return [
            'created' => $created->created_at ?? null,
            'updated' => $updated->updated_at ?? null,
        ];
    }

    /**
     * Enregistre ou met à jour des logements
     */
    private function setLogements($logements, $numcons)
    {
        foreach ($logements as $logement) {

            $datalog = [
                'numlog'    => $logement->numlog,
                'nbrres'    => $logement->nbrres,
                'niveau'    => $logement->niveau,
                'statut'    => $logement->statut,
                'typelog'   => $logement->typelog,
                'typeoccup' => $logement->typeoccup,
                'lien'      => $logement->lien,
                'numcons'   => $numcons,
                'stps'      => $logement->stps,
                'vve'       => $logement->vve,
                'lm'        => $logement->lm,
                'declarant' => $logement->declarant,
                'confort'   => $logement->confort,
                'phone'     => $logement->phone,
                'created_at' => $logement->created_at,
                'updated_at' => $logement->updated_at,
            ];

            DB::table('logement')->updateOrInsert(
                ['numlog' => $logement->numlog],
                $datalog
            );
        }
    }

    /**
     * Récupère l'extension du fichier
     */
    public function getFilename($file)
    {
        return pathinfo($file, PATHINFO_EXTENSION);
    }

    /**
     * Upload & synchronisation principale
     */
    public function upload(Request $request)
    {
        set_time_limit(0);

        $phone = $request->phone;
        Log::info("📱 Début synchronisation pour $phone");

        /** Vérification agent */
        $agent = DB::table("agent")
            ->where("phone", $request->phone)
            ->where("mdp", $request->mdp)
            ->first();

        if (!$agent) {
            Log::warning("❌ Agent non trouvé pour : $phone");
            return ["user" => false];
        }

        Log::info("✔ Agent validé : ID = {$agent->id}");

        // Récupération des constructions
        $constructions = json_decode($request->constructions);

        if (!$constructions) {
            Log::error("❌ Format constructions invalide");
            return ["error" => "Invalid JSON"];
        }

        /** Traiter chaque construction */
        foreach ($constructions as $construction) {

            // ---------- IMAGE ----------
            $filename = null;
            if (!empty($construction->image)) {
                $filename = $this->getFilename($construction->image);

                if ($request->file($construction->numcons)) {
                    $file = $request->file($construction->numcons);
                    $newName = "{$construction->numcons}.{$filename}";
                    $file->move(public_path('images'), $newName);

                    $construction->image = $newName;
                    Log::info("✔ Image enregistrée : $newName");
                }
            }

            // ---------- DATA ----------
            $data = [
                'numcons'      => $construction->numcons,
                'mur'          => $construction->mur ?? '',
                'ossature'     => $construction->ossature ?? '',
                'adress'       => $construction->adress ?? '',
                'toiture'      => $construction->toiture ?? '',
                'fondation'    => $construction->fondation ?? '',
                'typehab'      => $construction->typehab ?? '',
                'etatmur'      => $construction->etatmur ?? '',
                'access'       => $construction->access ?? '',
                'wc'           => $construction->wc ?? '',
                'typecons'     => $construction->typecons ?? '',
                'nbrniv'       => $construction->nbrniv ?? 0,
                'anconst'      => $construction->anconst ?? null,
                'idagt'        => $agent->id,
                'image'        => $construction->image ?? null,
                'typequart'    => $construction->typequart ?? '',
                'boriboritany' => $construction->boriboritany ?? '',
                'surface'      => $construction->surface ?? 0,
                'coord'        => isset($construction->lat, $construction->lng)
                    ? "{$construction->lat},{$construction->lng}"
                    : '',
                'idfoko'       => $construction->idfoko ?? null,
                'article'      => $construction->article ?? null,
                'created_at'   => $construction->created_at ?? now(),
                'updated_at'   => $construction->updated_at ?? now(),
                'numprop'      => $this->getProprietaire($construction->proprietaire ?? null),
            ];

            DB::table('construction')->updateOrInsert(
                ['numcons' => $construction->numcons],
                $data
            );

            Log::info("✔ Construction synchronisée : {$construction->numcons}");

            // ---------- LOGEMENTS ----------
            if (!empty($construction->logements)) {
                $this->setLogements($construction->logements, $construction->numcons);
            }
        }

        Log::info("🎉 Synchronisation terminée pour l'agent {$agent->id}");

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
