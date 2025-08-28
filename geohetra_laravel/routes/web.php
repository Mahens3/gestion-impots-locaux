<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\IfpbController;
use App\Http\Controllers\AgentController;
use App\Http\Controllers\ControlController;
use App\Http\Controllers\TerrainController;
use App\Http\Controllers\LogementController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\FokontanyController;
use App\Http\Controllers\ParametreController;
use App\Http\Controllers\CoordonneesController;
use App\Http\Controllers\ConnectivityController;
use App\Http\Controllers\ConstructionController;
use App\Http\Controllers\ProprietaireController;

Route::pattern('reactroute','[a-z-A-Z0-9-/]+');
Route::get('{reactroute}', function () {
    return view('index');
})->where('reactroute','((?!api).)*$');
/**
Route::get('api/dashboard', [DashboardController::class, 'dashboard']);
Route::get('/api/complete', [ConnectivityController::class, 'completeData']);


Route::get('api/coordonnees', [CoordonneesController::class, 'part']);
Route::post('api/coordonnees/get', [CoordonneesController::class, 'getcoord']);

Route::get('api/coordonnees/get', [CoordonneesController::class, 'getcoord']);

Route::get('api/correction', [ControlController::class, 'correction']);


Route::get('api/construction/liste', [ConstructionController::class, 'index']);
Route::post('api/construction/add', [ConstructionController::class, 'store']);
Route::post('api/upload', [ConstructionController::class, 'upload']);
Route::post('api/construction/update', [ConstructionController::class, 'update']);
Route::post('api/construction/setprop', [ConstructionController::class, 'setprop']);
Route::post('api/construction/setifpb', [ConstructionController::class, 'setifpb']);
Route::post('api/construction/setimage', [ConnectivityController::class, 'setimage']);
Route::post('api/construction/checked', [ConstructionController::class, 'checkedConstruction']);
Route::get('api/construction/delete/{id}', [ConstructionController::class, 'destroy']);
Route::get('construction/delete/{id}', [ConstructionController::class, 'destroy']);


Route::get('api/agent/all', [AgentController::class, 'index']);
Route::post('api/agent/add', [AgentController::class, 'store']);
Route::post('api/agent/update', [AgentController::class, 'update']);
Route::get('api/agent/delete/{id}', [AgentController::class, 'delete']);


*/


