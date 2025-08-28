<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\IfpbController;
use App\Http\Controllers\AgentController;
use App\Http\Controllers\FetchController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\ProcessController;
use App\Http\Controllers\LogementController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FokontanyController;
use App\Http\Controllers\ParametreController;
use App\Http\Controllers\ConstructionController;
use App\Http\Controllers\ProprietaireController;
use App\Http\Controllers\RemoteAccessController;
use App\Http\Controllers\ConnectivityController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('/login', [AuthController::class, 'login']);

Route::post('/agent/auth', [ConnectivityController::class, 'login']);

//Route::middleware('jwt.verify')->get('/construction/page/{page}', [FetchController::class, 'findDefault']);

Route::get('/construction/page/{page}', [FetchController::class, 'findDefault']);

Route::get('/agt-fkt', [FetchController::class, 'findAgtFkt']);

Route::get('/normalise', [FetchController::class, 'updating']);
Route::get('/triage', [FetchController::class, 'triage']);


/***** construction *****/

Route::get('/image/{image}', [FetchController::class, 'image']);

Route::get("/construction/perfkt/{idfoko}", [ProcessController::class, "getIfpbByFokontany"]);
Route::get('/construction/base64/{image}', [FetchController::class, 'base64']);
Route::get('/avis/page={page}&nbrperpage={nbr}&fokontany={fokontany}', [FetchController::class, 'findAllForAvis']);

Route::get('/construction/map/{idfoko}', [FetchController::class, 'findForMap']);
Route::get('/construction/search/page={page}&value={value}', [FetchController::class, 'search']);

Route::get('/dashboard', [FetchController::class, 'dashboard']);
Route::get('/dashboard-enq', [FetchController::class, 'dashboardEnq']);

Route::get('/construction/bycons/{construction}', [FetchController::class, 'findByNumcons']);
Route::get('/construction/{numcons}', [FetchController::class, 'find']);
Route::post('/construction', [ConstructionController::class, 'store']);
Route::post('/update/construction', [ConstructionController::class, 'update']);
Route::post('/construction/addmultiple', [ConstructionController::class, 'addMultiple']);
Route::delete('/construction/{numcons}', [ConstructionController::class, 'store']);
Route::post('/addimage', [ConstructionController::class, 'addImage']);

/***** propriètaire *****/
Route::get('/proprietaire', [ProprietaireController::class, 'index']);
//Route::get('/complete', [DashboardController::class, 'completeData']);
Route::post('/proprietaire', [ProprietaireController::class, 'store']);
Route::put('/proprietaire', [ProprietaireController::class, 'update']);
Route::delete('/proprietaire/{id}', [ProprietaireController::class, 'destroy']);

/***** logement *****/
Route::get('/logement', [LogementController::class, 'index']);
Route::post('/logement', [LogementController::class, 'store']);
Route::put('/logement', [LogementController::class, 'update']);
Route::delete('/delete/{id}', [LogementController::class, 'destroy']);


/***** parametre *****/
Route::get('/parametre', [ParametreController::class, 'index']);
Route::post('/parametre', [ParametreController::class, 'store']);
Route::put('/parametre', [ParametreController::class, 'update']);
Route::delete('/parametre/{id}', [ParametreController::class, 'destroy']);

/***** agent *****/
Route::get('agent', [AgentController::class, 'index']);
Route::post('agent', [AgentController::class, 'store']);
Route::put('agent', [AgentController::class, 'update']);
Route::delete('agent/{id}', [AgentController::class, 'destroy']);

/***** fokontany *****/
Route::get('/fokontany', [FokontanyController::class, 'index']);
Route::post('/fokontany', [FokontanyController::class, 'store']);
Route::post('/fokontany', [FokontanyController::class, 'update']);
Route::get('/fokontany/{id}', [FokontanyController::class, 'delete']);

Route::post('/download', [RemoteAccessController::class, 'download']);
Route::post('/upload', [RemoteAccessController::class, 'upload']);

Route::get('/payment', [PaymentController::class, "index"]);
Route::post('/payment/add', [PaymentController::class, "store"]);
Route::post('/payment/update', [PaymentController::class, "update"]);



