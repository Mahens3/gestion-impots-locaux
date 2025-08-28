export const typeconstruction = {
    "mur": {
        "title" : "Mur",
        "type": "select",
        "options": [
            "Néant", "Pisé", "Brique cuite", "Tôle", "Planche", "Végétal", "Brique crue", "Parpaing", "Pierre", "Pierre", "Bois de qualité", "Préfabriqué", "Béton"
        ]
    },
    "ossature": {
        "title" : "Ossature",
        "type": "select",
        "options": [
            "Bois", "Brique crue", "Brique cuite", "Pierre", "Béton"
        ]
    },
    "toiture": {
        "title" : "Toiture",
        "type": "select",
        "options": [
            "Chaume/précaire", "Tôle", "Tuiles", "Béton"
        ]
    },
    "fondation": {
        "title" : "Fondation",
        "type": "select",
        "options": [
            "Néant", "Brique cuite", "Brique crue", "Béton", "Pierre", "Ciment et pierre", "Pisé", "Sur pilotis"
        ]
    },
    "typehab": {
        "title" : "Type habitat",
        "type": "select",
        "options": [
            "Précaire", "Traditionnel", "Moderne", "Haut standing"
        ]
    },
    "etatmur": {
        "title" : "Etat du mur",
        "type": "select",
        "options": [
            "Très bon", "Bon", "Moyen", "Degradé"
        ]
    },

    "access": {
        "title" : "Accéssibilité",
        "type": "select",
        "options": [
            "Chemin", "Piste", "Goudron/Pavé"
        ]
    },
    "nbrniv": { 
        "title" : "Nombre de niveau",
        "type": "field" 
    },
    "anconst": { 
        "title" : "Année de la construction",
        "type": "field" 
    },
    "surface": { 
        "title" : "Surface(en m²)",
        "type": "field" 
    },
    "adress": { 
        "title" : "Adresse(Lot)",
        "type": "field" 
    },
    "article": { 
        "title" : "Article",
        "type": "field" 
    },
    "typequart": {
        "title" : "Type quartier", 
        "type": "select",
        "options": ["Popularire salubre", "Semi-residentiel"],
    },
    /**
    "wc": {
        "type": "radio",
        "title": "Possedant un WC",
        "options": ["oui", "non"]
    }, */
     "boriboritany": {
        "title" : "Boriboritany", 
        "type": "field" 
    },
}

// A4 minimum
// 8x12 minimum
// US Letter minimum

export const typeproprietaire = {
    "nomprop": { 
        "title" : "Nom propriétiare",
        "type": "field" 
    
    }, 
    "prenomprop": { 
        "title" : "Prenoms propriétaire",
        "type": "field" 
    }, 
    "adress": {
        "title" : "Adresse du propriétaire" ,
        "type": "field" 
    }
}


export const typeifpb = {
    "article": { 
        "title" : "Article",
        "type": "field" 
    
    }, 
    "role": { 
        "title" : "Role",
        "type": "field" 
    }, 
}

export const typelogement = {
    "niveau": {
        "title" : "Niveau",
        "type": "select",
        "options": ["Rez de chaussée", "1e etage", "2e etage", "3e etage", "4e etage", "5e etatge"]
    },
    "statut": {
        "title" : "Statut",
        "type" : "select",
        "options": ["Familial", "Entreprise privée", "Secteur public", "Association ou ONG", "Loisirs"]
    },
    "typelog": {
        "title" : "Usage" ,
        "type": "select",
        "options": ["Habitat", "Bureau", "Commerce", "Hôtellerie", "Banque ou microfinance", "Industrie", "Artisanat", "Dépôt", "Education", "Santé"]
    },
    "typeoccup": {
        "title" : "Type occupant",
        "type": "select",
        "options": ["Propriétaire", "Locataire", "Occupant gratuit"]
    },
    "confort": {
        "title" : "Confort",
        "type": "checkbox",
        "options": ["Garage", "Ecran plat", "Wifi", "Parabole", "WC interne", "Douche interne", "Salle d'eau", "Eau", "Electricité", "Cuisine interne", "Evacuation des eaux usées"]
    },
    "stpp": {
        "title" : "Surface du logement(en m²)",
        "type": "field",
    },

    "declarant": {
        "title" : "Declarant",
        "type": "field",
    },

    "lien": {
        "title" : "Lien par rapport au chef du logement",
        "type" : "field"
    }
}