<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('payment', function (Blueprint $table) {
            $table->integer("id")->autoIncrement();
            $table->date('datePayment')->nullable();
            $table->time('timePayment')->nullable();
            $table->string('quittance')->nullable();
            $table->integer('montant')->nullable();
            $table->string('numcons', 30);

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
        //
    }
};
