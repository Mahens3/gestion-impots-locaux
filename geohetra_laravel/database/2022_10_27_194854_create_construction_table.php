<?php
/**
 SELECT c.* FROM construction c, data2022 d, proprietaire p WHERE c.numprop=p.numprop AND CONCAT(LOWER(p.nomprop), ' ', LOWER(p.prenomprop))=LOWER(d.NOM) and c.numif is NULL; 
*/
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateConstructionTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('fokontany', function (Blueprint $table) {
            $table->integer("id")->primary();
            $table->string('nomfokontany');
            $table->integer('rang');
        });

        Schema::create('agent', function (Blueprint $table) {
            $table->integer("id")->primary();
            $table->string('phone');
            $table->string('nom');
            $table->integer('numequip');
            $table->string('mdp');
            $table->string('type');
        });

        Schema::create('coordonnees', function (Blueprint $table) {
            $table->integer("id")->primary();
            $table->float('lat')->nullable();
            $table->float('lng')->nullable();
            $table->string('typequart')->nullable();
            $table->string('etat')->nullable();
            $table->date('dateattr')->nullable();
            $table->date('dateret')->nullable();
            $table->integer('idfoko')->nullable();
            $table->integer('idagt')->nullable();

            $table->foreign('idfoko')
            ->references('id')
            ->on('fokontany')
            ->onDelete('cascade')
            ->onUpdate('cascade');

            $table->foreign('idagt')
                    ->references('id')
                    ->on('agent')
                    ->onDelete('cascade')
                    ->onUpdate('cascade');
        });


        Schema::create('proprietaire', function (Blueprint $table) {
            $table->string('numprop')->primary();
            $table->string('nomprop')->nullable();
            $table->string('prenomprop')->nullable();
            $table->string('propriete')->nullable();
            $table->string('adress')->nullable();
            $table->string('typeprop')->nullable();
            $table->integer('id')->nullable();
            $table->dateTime('datetimes')->nullable();
        });

        Schema::create('ifpb', function (Blueprint $table) {
            $table->string('numifpb')->primary();
            $table->integer('numcons')->nullable();
            $table->string('rem')->nullable();
            $table->integer('numlog')->nullable();
            $table->string('nomprop')->nullable();
            $table->string('prenomprop')->nullable();
            $table->string('adrprop')->nullable();
            $table->string('numprop')->nullable();
            $table->integer('id')->nullable();
            $table->dateTime('datetimes')->nullable();
        });

        Schema::create('construction', function (Blueprint $table) {
            $table->string('numcons')->primary();
            $table->integer('idcoord')->nullable();
            $table->string('mur')->nullable();
            $table->string('ossature')->nullable();
            $table->string('geometry')->nullable();
            $table->string('toiture')->nullable();
            $table->string('fondation')->nullable();
            $table->string('typehab')->nullable();
            $table->string('etatmur')->nullable();
            $table->string('access')->nullable();
            $table->integer('nbrhab')->nullable();
            $table->integer('nbrniv')->nullable();
            $table->string('anconst')->nullable();
            $table->integer('nbrcom')->nullable();
            $table->integer('nbrbur')->nullable();
            $table->integer('nbrprop')->nullable();
            $table->integer('nbrloc')->nullable();
            $table->integer('nbrocgrat')->nullable();
            $table->float('surface')->nullable();
            $table->float('area')->nullable();
            $table->string('coord')->nullable();
            $table->integer('idfoko')->nullable();
            $table->string('numter')->nullable();
            $table->string('numif')->nullable();
            $table->string('numprop')->nullable();
            $table->integer('id')->nullable();
            $table->dateTime('datetimes')->nullable();
            $table->string('adress')->nullable();
            $table->string('image')->nullable();

            $table->foreign('idcoord')
                  ->references('id')
                  ->on('coordonnees')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');

            $table->foreign('numif')
                  ->references('numifpb')
                  ->on('ifpb')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            
            $table->foreign('numprop')
                  ->references('numprop')
                  ->on('proprietaire')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            
            $table->foreign('idfoko')
            ->references('id')
            ->on('fokontany')
            ->onDelete('cascade')
            ->onUpdate('cascade');

        });

        Schema::create('logement', function (Blueprint $table) {
            $table->string('numlog')->primary();
            $table->integer('nbrres')->nullable();
            $table->integer('niveau')->nullable();
            $table->string('statut')->nullable();
            $table->string('typelog')->nullable();
            $table->string('typeoccup')->nullable();
            $table->string('vlmeprop')->nullable();
            $table->string('vve')->nullable();
            $table->string('lm')->nullable();
            $table->string('vlmeoc')->nullable();
            $table->string('confort')->nullable();
            $table->string('phone')->nullable();
            $table->string('valrec')->nullable();
            $table->integer('nbrpp')->nullable();
            $table->integer('stpp')->nullable();
            $table->integer('nbrps')->nullable();
            $table->integer('stps')->nullable();
            $table->string('numcons')->nullable();
            $table->dateTime('datetimes')->nullable();
            $table->integer('id')->nullable();
            $table->string('declarant')->nullable();
            $table->string('lien')->nullable();

            $table->foreign('numcons')
                  ->references('numcons')
                  ->on('construction')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });

        Schema::create('personne', function (Blueprint $table) {
            $table->string('numpers')->primary();
            $table->string('sexe')->nullable();
            $table->integer('age')->nullable();
            $table->string('profession')->nullable();
            $table->string('lieu')->nullable();
            $table->dateTime('datetimes')->nullable();
            $table->string('numcons')->nullable();
            $table->integer('id')->nullable();


            $table->foreign('numcons')
                  ->references('numcons')
                  ->on('construction')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
        });

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {

        Schema::dropIfExists('agent');

        Schema::dropIfExists('fokontany');

        Schema::dropIfExists('coordonnees');

        Schema::dropIfExists('construction');

        Schema::dropIfExists('proprietaire');

        Schema::dropIfExists('logement');

    }
}
