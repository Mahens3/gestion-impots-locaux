<?php

namespace App\Http\Controllers;
use App\Models\Payment;
use App\Models\Construction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\CalculIFPB;

class PaymentController extends Controller
{
    public function index($idfoko)
    {
        $payment = Payment::with("construction.proprietaire");
        if($idfoko>0){
            $payment->whereHas("construction", function($query) use ($idfoko){
                $query->whereRaw("idfoko=?", [$idfoko]);
            });
        }

        $payment = $payment->get();
        return ["payments" => $payment];
    }

    public function store(Request $request)
    {
        $payment = Payment::create([
            'numcons' => $request->numcons,
            'datePayment' =>$request->datePayment,
            'timePayment' => $request->timePayment,
            'montant' => $request->montant,
            'quittance' => $request->quittance,
        ]);
        return $payment; 
    }

    public function update(Request $request)
    {
        DB::table('payment')->where("id", $request->id)->update([
            'numcons' => $request->numcons,
            'montant' => $request->montant,
            'quittance' => $request->quittance,
        ]);

        $payment = DB::table('payment')->find($request->id);
        return $payment;
    }
}
