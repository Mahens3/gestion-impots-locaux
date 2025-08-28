import React from 'react'
import { useRef, useState } from 'react';
import { Table } from './table';

export const ConstructionCard = (props) => {
    return (
        <div className="container">
            <div className="card card-impot">
                <div className="card-header">
                    <div className="space-between">
                        <h3>Construction</h3> <button href="#" onClick={props.handleModal} className='btn btn-secondary' style={{ fontSize: 12, letterSpacing: "1.4px" }}><i className='fa fa-pencil fa-solid'></i> Modifier</button>
                    </div>

                </div>
                <div className="card-body">
                    <div className="col-md-6">
                        <label htmlFor="">Mur</label> : <span>{props.data["mur"]}</span>
                        <br />
                        <label htmlFor="">Ossature</label> : <span> {props.data["ossature"]} </span>
                        <br />
                        <label htmlFor="">Toiture</label> : <span> {props.data["toiture"]} </span>
                        <br />
                        <label htmlFor="">Fondation</label> : <span> {props.data["fondation"]} </span>
                        <br />
                        <label htmlFor="">Type habitat</label> : <span> {props.data["typehab"]} </span>
                        <br />
                        <label htmlFor="">Etat du mur</label> : <span> {props.data["etatmur"]} </span>
                        <br />
                        <label htmlFor="">Accéssibilité</label> : <span> {props.data["access"]} </span>
                        <br />
                        <label htmlFor="">Nombre de niveau</label> : <span> {props.data["nbrniv"]} </span>
                        <br />
                        <label htmlFor="">Année de construction</label> : <span> {props.data["anconst"]} </span>
                        <br />
                    </div>
                    <div className="col-md-6">
                        <label htmlFor="">Nombre d'habitation</label> : <span> {props.data["nbrhab"]} </span>
                        <br />
                        <label htmlFor="">Nombre de logement pour commerce</label> : <span> {props.data["nbrcom"]} </span>
                        <br />
                        <label htmlFor="">Nombre de bureau</label> : <span> 4 </span>
                        <br />
                        <label htmlFor="">Nombre de logement pour le proprietaire</label> : <span> {props.data["nbrprop"]} </span>
                        <br />
                        <label htmlFor="">Nombre de logement pour locataire</label> : <span> {props.data["nbrloc"]} </span>
                        <br />
                        <label htmlFor="">Nombre de logement pour occupant gratuit</label> : <span> {props.data["nbrocgrat"]} </span>
                        <br />
                        <label htmlFor="">Surface de la construction par rapport au sol</label> : <span> {props.data["surf"]} </span>
                        <br />
                    </div>
                </div>
            </div>

        </div>
    )
}

export const ProprietaireCard = (props) => {
    return (
        <div className="container">
            <div className="card card-impot">
                <div className="card-header">
                    <div className="space-between">
                        <h3>Propriétaire</h3>
                        <button href="#" onClick={props.handleModal} className='btn btn-secondary' style={{ fontSize: 12, letterSpacing: "1.4px" }}><i className='fa fa-pencil fa-solid'></i> Modifier</button>
                    </div>

                </div>
                <div className="card-body">
                    <div className="col-md-6">
                        <label htmlFor="">Nom</label> : <span> {props.data["nom"]} </span>
                        <br />
                        <label htmlFor="">Prénoms</label> : <span> {props.data["prenom"]} </span>
                        <br />
                        <label htmlFor="">Adresse</label> : <span> {props.data["adresse"]} </span>
                        <br />
                    </div>

                </div>
            </div>
        </div>
    )
}

export const IFPBCard = (props) => {
    return (
        <div className="container">
            <div className="card card-impot" >
                <div className="card-header">
                    <div className="space-between">
                        <h3>IFPB</h3>
                        <button href="#" onClick={props.handleModal} className='btn btn-secondary' style={{ fontSize: 12, letterSpacing: "1.4px" }}><i className='fa fa-pencil fa-solid'></i> Modifier</button>
                    </div>

                </div>
                <div className="card-body">
                    <div className="col-md-6">
                        <label htmlFor="">Exonération</label> : <span> {props.data["exon"]} </span>
                        <br />

                        <label htmlFor="">Cause</label> : <span> {props.data["cause"]} </span>
                        <br />

                        <label htmlFor="">Dernière année de l'avis</label> : <span> {props.data["dernavis"]} </span>
                        <br />

                        <label htmlFor="">Montant inscrit</label> : <span> {props.data["montantins"]} </span>
                        <br />

                        <label htmlFor="">Montant payé</label> : <span> {props.data["montantpaye"]} </span>
                        <br />

                        <label htmlFor="">Article</label> : <span> {props.data["article"]} </span>
                        <br />

                        <label htmlFor="">Role</label> : <span> {props.data["role"]} </span>
                        <br />
                    </div>

                </div>
            </div>
        </div>
    )
}

export const LogementCard = (props) => {
    const keys = ["nbrres","niveau","statut","typelog","typeoccup","vlmeprop","vve","lm","vlmeoc","valrec","confort","phone","nbrpp","stpp","nbrps","stps"]
    const header = ["Nombre de residents", "Niveau","Statut","Type logement","Type occupant","Loyer mensuel(propriétaire)", "Valeur vénale", "Loyer mensuel(Occupant gratuit)","Loyer mensuel(Occupant gratuit)", "Loyer mensuel(agent)","Confort","Téléphone", "Nombre de pièce principale", "Surface totale de pièce principale" , "Nombre de pièce secondaire", "Surface totale de pièce secondaire"]
    const logements = [
        {
          "numlog" : 1,
          "nbrres": 105,
          "niveau": 0,
          "statut": "c769fe7b-dadf-4aaf-83f0-28368c4e8bc7",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,514.52",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 29,
          "lm": 30,
          "vlmeoc": 37,
          "valrec": "male",
          "confort": 25,
          "phone": 29,
          "nbrpp": 39,
          "stpp": 938,
          "nbrps": "wildawise@neteria.com",
          "stps": 0
        },
        {
          "numlog" : 1,
          "nbrres": 842,
          "niveau": 1,
          "statut": "501943f7-a600-4838-be47-e576b5155d78",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,980.04",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 29,
          "lm": 30,
          "vlmeoc": 30,
          "valrec": "female",
          "confort": 32,
          "phone": 34,
          "nbrpp": 40,
          "stpp": 194,
          "nbrps": "wildawise@neteria.com",
          "stps": 1
        },
        {
          "numlog" : 1,
          "nbrres": 475,
          "niveau": 2,
          "statut": "9cdf19b6-123a-4a6a-b7dc-5bd949e00a38",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,725.20",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 20,
          "lm": 33,
          "vlmeoc": 37,
          "valrec": "female",
          "confort": 32,
          "phone": 23,
          "nbrpp": 38,
          "stpp": 194,
          "nbrps": "wildawise@neteria.com",
          "stps": 2
        },
        {
          "numlog" : 1,
          "nbrres": 651,
          "niveau": 3,
          "statut": "e6304859-9c2e-4466-816d-3bb4cfedf8f8",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$3,302.33",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 38,
          "lm": 26,
          "vlmeoc": 33,
          "valrec": "female",
          "confort": 40,
          "phone": 24,
          "nbrpp": 31,
          "stpp": 332,
          "nbrps": "wildawise@neteria.com",
          "stps": 3
        },
        {
          "numlog" : 1,
          "nbrres": 481,
          "niveau": 4,
          "statut": "2a58b59f-b13d-42e7-b71f-17267bfdcf29",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$3,112.28",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 38,
          "lm": 32,
          "vlmeoc": 31,
          "valrec": "female",
          "confort": 23,
          "phone": 31,
          "nbrpp": 39,
          "stpp": 744,
          "nbrps": "wildawise@neteria.com",
          "stps": 4
        },
        {
          "numlog" : 1,
          "nbrres": 107,
          "niveau": 5,
          "statut": "6a42d7b9-8735-4d0d-a748-87ea443d908b",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,364.48",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 34,
          "lm": 23,
          "vlmeoc": 35,
          "valrec": "female",
          "confort": 25,
          "phone": 37,
          "nbrpp": 38,
          "stpp": 468,
          "nbrps": "wildawise@neteria.com",
          "stps": 5
        },
        {
          "numlog" : 1,
          "nbrres": 194,
          "niveau": 6,
          "statut": "5565c129-e9b9-4ccd-9018-719ea9486495",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,805.89",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 30,
          "lm": 24,
          "vlmeoc": 38,
          "valrec": "female",
          "confort": 30,
          "phone": 39,
          "nbrpp": 33,
          "stpp": 258,
          "nbrps": "wildawise@neteria.com",
          "stps": 6
        },
        {
          "numlog" : 1,
          "nbrres": 620,
          "niveau": 7,
          "statut": "98afeaea-b072-400a-96a5-e125bd6c24be",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,497.73",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 35,
          "lm": 36,
          "vlmeoc": 35,
          "valrec": "female",
          "confort": 33,
          "phone": 39,
          "nbrpp": 24,
          "stpp": 554,
          "nbrps": "wildawise@neteria.com",
          "stps": 7
        },
        {
          "numlog" : 1,
          "nbrres": 657,
          "niveau": 8,
          "statut": "76ef85d9-6bb9-4ad2-a8c8-845d3f813e7e",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,506.80",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 35,
          "lm": 28,
          "vlmeoc": 22,
          "valrec": "female",
          "confort": 39,
          "phone": 39,
          "nbrpp": 38,
          "stpp": 351,
          "nbrps": "wildawise@neteria.com",
          "stps": 8
        },
        {
          "numlog" : 1,
          "nbrres": 373,
          "niveau": 9,
          "statut": "b00a809e-2d08-4f0d-a9bc-965bdc49cc35",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,952.26",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 37,
          "lm": 25,
          "vlmeoc": 30,
          "valrec": "female",
          "confort": 40,
          "phone": 28,
          "nbrpp": 38,
          "stpp": 471,
          "nbrps": "wildawise@neteria.com",
          "stps": 9
        },
        {
          "numlog" : 1,
          "nbrres": 899,
          "niveau": 10,
          "statut": "b3d86c1b-f4dd-4e1d-a59d-8a19ce453e9d",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,483.35",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 36,
          "lm": 33,
          "vlmeoc": 32,
          "valrec": "female",
          "confort": 27,
          "phone": 33,
          "nbrpp": 20,
          "stpp": 179,
          "nbrps": "wildawise@neteria.com",
          "stps": 10
        },
        {
          "numlog" : 1,
          "nbrres": 538,
          "niveau": 11,
          "statut": "c7a7c050-4336-4886-91a9-df48984290fc",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,768.65",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 33,
          "lm": 35,
          "vlmeoc": 22,
          "valrec": "female",
          "confort": 20,
          "phone": 34,
          "nbrpp": 26,
          "stpp": 773,
          "nbrps": "wildawise@neteria.com",
          "stps": 11
        },
        {
          "numlog" : 1,
          "nbrres": 920,
          "niveau": 12,
          "statut": "d2fbfc7d-007a-42fd-9203-fe109df5f516",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,818.85",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 21,
          "lm": 23,
          "vlmeoc": 36,
          "valrec": "female",
          "confort": 37,
          "phone": 37,
          "nbrpp": 31,
          "stpp": 101,
          "nbrps": "wildawise@neteria.com",
          "stps": 12
        },
        {
          "numlog" : 1,
          "nbrres": 433,
          "niveau": 13,
          "statut": "bcba99d3-fdbc-4e41-8bd3-f8e4824ace80",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,291.75",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 20,
          "lm": 37,
          "vlmeoc": 34,
          "valrec": "female",
          "confort": 37,
          "phone": 20,
          "nbrpp": 39,
          "stpp": 224,
          "nbrps": "wildawise@neteria.com",
          "stps": 13
        },
        {
          "numlog" : 1,
          "nbrres": 660,
          "niveau": 14,
          "statut": "9d3aa207-e2d7-4632-bb53-7bb465c41cdd",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$3,208.09",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 27,
          "lm": 28,
          "vlmeoc": 21,
          "valrec": "female",
          "confort": 36,
          "phone": 28,
          "nbrpp": 38,
          "stpp": 590,
          "nbrps": "wildawise@neteria.com",
          "stps": 14
        },
        {
          "numlog" : 1,
          "nbrres": 371,
          "niveau": 15,
          "statut": "99536256-56f8-4964-8a26-3d957412c8a1",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,773.14",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 34,
          "lm": 40,
          "vlmeoc": 38,
          "valrec": "female",
          "confort": 26,
          "phone": 35,
          "nbrpp": 25,
          "stpp": 951,
          "nbrps": "wildawise@neteria.com",
          "stps": 15
        },
        {
          "numlog" : 1,
          "nbrres": 968,
          "niveau": 16,
          "statut": "de10f088-e638-4f5e-8069-52db149e50c7",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,845.75",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 39,
          "lm": 23,
          "vlmeoc": 27,
          "valrec": "female",
          "confort": 35,
          "phone": 40,
          "nbrpp": 33,
          "stpp": 110,
          "nbrps": "wildawise@neteria.com",
          "stps": 16
        },
        {
          "numlog" : 1,
          "nbrres": 982,
          "niveau": 17,
          "statut": "28b9e23b-ae41-4a56-b70b-56339ad35ca1",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,974.53",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 39,
          "lm": 25,
          "vlmeoc": 37,
          "valrec": "female",
          "confort": 32,
          "phone": 35,
          "nbrpp": 24,
          "stpp": 116,
          "nbrps": "wildawise@neteria.com",
          "stps": 17
        },
        {
          "numlog" : 1,
          "nbrres": 420,
          "niveau": 18,
          "statut": "3c23da38-d34b-4ecf-9ea0-9be0d915738b",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$3,356.30",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 38,
          "lm": 37,
          "vlmeoc": 36,
          "valrec": "female",
          "confort": 21,
          "phone": 34,
          "nbrpp": 31,
          "stpp": 671,
          "nbrps": "wildawise@neteria.com",
          "stps": 18
        },
        {
          "numlog" : 1,
          "nbrres": 175,
          "niveau": 19,
          "statut": "282b6ecb-182c-4cd0-8f3f-f39e6c026d8e",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,643.66",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 22,
          "lm": 23,
          "vlmeoc": 23,
          "valrec": "female",
          "confort": 37,
          "phone": 30,
          "nbrpp": 30,
          "stpp": 334,
          "nbrps": "wildawise@neteria.com",
          "stps": 19
        },
        {
          "numlog" : 1,
          "nbrres": 634,
          "niveau": 20,
          "statut": "14bbb044-fab3-43aa-b39f-d61256c430ca",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,588.60",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 37,
          "lm": 35,
          "vlmeoc": 24,
          "valrec": "female",
          "confort": 28,
          "phone": 20,
          "nbrpp": 22,
          "stpp": 964,
          "nbrps": "wildawise@neteria.com",
          "stps": 20
        },
        {
          "numlog" : 1,
          "nbrres": 322,
          "niveau": 21,
          "statut": "18d363c3-b078-4470-b667-61caba03426b",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,005.28",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 31,
          "lm": 34,
          "vlmeoc": 33,
          "valrec": "female",
          "confort": 37,
          "phone": 33,
          "nbrpp": 35,
          "stpp": 624,
          "nbrps": "wildawise@neteria.com",
          "stps": 21
        },
        {
          "numlog" : 1,
          "nbrres": 218,
          "niveau": 22,
          "statut": "8c382116-df81-4043-8ee9-2c9e6f59cc46",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,171.15",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 31,
          "lm": 35,
          "vlmeoc": 28,
          "valrec": "female",
          "confort": 33,
          "phone": 34,
          "nbrpp": 31,
          "stpp": 762,
          "nbrps": "wildawise@neteria.com",
          "stps": 22
        },
        {
          "numlog" : 1,
          "nbrres": 929,
          "niveau": 23,
          "statut": "246d9c25-bd3e-48a6-8b12-01eb805732b8",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,004.79",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 20,
          "lm": 36,
          "vlmeoc": 37,
          "valrec": "female",
          "confort": 38,
          "phone": 40,
          "nbrpp": 26,
          "stpp": 697,
          "nbrps": "wildawise@neteria.com",
          "stps": 23
        },
        {
          "numlog" : 1,
          "nbrres": 596,
          "niveau": 24,
          "statut": "e5a7e2d2-fbc1-4544-9718-f18239a825d2",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$3,119.18",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 22,
          "lm": 28,
          "vlmeoc": 33,
          "valrec": "female",
          "confort": 23,
          "phone": 25,
          "nbrpp": 34,
          "stpp": 272,
          "nbrps": "wildawise@neteria.com",
          "stps": 24
        },
        {
          "numlog" : 1,
          "nbrres": 885,
          "niveau": 25,
          "statut": "cf4c5bfd-de3a-4ac0-b6e6-1cd34c75fce1",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$1,378.11",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 36,
          "lm": 21,
          "vlmeoc": 26,
          "valrec": "female",
          "confort": 21,
          "phone": 35,
          "nbrpp": 40,
          "stpp": 104,
          "nbrps": "wildawise@neteria.com",
          "stps": 25
        },
        {
          "numlog" : 1,
          "nbrres": 144,
          "niveau": 26,
          "statut": "7115de41-1ece-41e6-8138-38c25ab276a1",
          "typelog": "<ReferenceError: booltoiture is not defined>",
          "typeoccup": "$2,765.83",
          "vlmeprop": "http://placehold.it/32x32",
          "vve": 36,
          "lm": 23,
          "vlmeoc": 36,
          "valrec": "female",
          "confort": 27,
          "phone": 35,
          "nbrpp": 35,
          "stpp": 607,
          "nbrps": "wildawise@neteria.com",
          "stps": 26
        }
    ]

    const handleSelected = (selected) => {
      props.setSelectedLogement(selected)
    }
    return (
        <div className="container">
            <div className="card" >
                <div className="card-header">
                    <div className="space-between">
                        <h3>Logements</h3>
                    </div>
                </div>
                <div className="card-body">
                    <Table
                        rows={logements}
                        header={header}
                        keys={keys}
                        handleSelected={handleSelected}
                    />
                </div>
            </div>
        </div>

    )
}