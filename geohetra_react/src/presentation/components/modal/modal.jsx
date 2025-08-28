import { useState, useEffect } from 'react';
import {
    Modal,
    Fade,
    Box,
    TextField,
    Button,
    Select,
    MenuItem,
    FormControl,
    InputLabel,
    Typography,
} from '@mui/material';
import axios from '../../../data/api/axios';
import { Close } from '@mui/icons-material';

import { toast } from "react-toastify";
import { getDate, getTime } from "../../helpers/date";

const get1 = (name, data) => {
    return data == null ? "" : data[name];
};

const Selected = ({ colonne, colonnes, handleChange }) => {
    const [value, setValue] = useState(colonne);

    const onChange = (e) => {
        setValue(e.target.value);
        handleChange(e.target.value);
    };

    return (
        <FormControl fullWidth>
            <InputLabel style={{ color: 'green' }} htmlFor='colonne-select'>Colonne</InputLabel>
            <Select
                color='success'
                value={value}
                onChange={onChange}
                label='Colonne'
            >
                {Object.keys(colonnes).map((key) => (
                    <MenuItem key={key} value={key}>
                        {colonnes[key]}
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
    );
};

export const FormParametre = ({ closeModal, parametre }) => {
    const [isSent, setIsSent] = useState(false);
    const [entity, setEntity] = useState(get1("entity", parametre));
    const [colonne, setColonne] = useState(get1("colonne", parametre));
    const [valeur, setValeur] = useState(get1("valeur", parametre));
    const [coeff, setCoeff] = useState(get1("coeff", parametre));

    const [colonnes, setColonnes] = useState([]);

    const typeEntity = {
        "construction": { "mur": "Mur", "etatmur": "Etat du mur", "ossature": "Ossature", "fondation": "Fondation", "toiture": "Toiture", "typecons": "Type construction", "typequart": "Type quartier", "access": "Accéssibilité" },
        "logement": { "confort": "Confort", "typelog": "Usage" }
    };

    const handleEntity = (e) => {
        setEntity(e.target.value);
        setColonnes(typeEntity[e.target.value]);
        if (e.target.value === "construction") {
            setColonne("mur");
        } else {
            setColonne("confort");
        }
    };

    const send = () => {
        setIsSent(true);
        var data = {
            entity: entity,
            colonne: colonne,
            designation: typeEntity[entity][colonne],
            valeur: valeur,
            coeff: coeff
        };
        if (parametre !== undefined) {
            data['id'] = parametre["id"];
        }
        console.log(data);
        axios.post(
            parametre == undefined
                ? "api/parametre/add"
                : "api/parametre/update",
            data
        )
            .then(() => {
                setIsSent(false);
            });
    };

    useEffect(() => {
        if (parametre == undefined) {
            setEntity("construction");
            setColonnes(typeEntity["construction"]);
            setColonne("mur");
        } else {
            setEntity(parametre.entity);
            setColonnes(typeEntity[parametre.entity]);
            setColonne(parametre.colonne);
            setValeur(parametre.valeur);
            setCoeff(parametre.coeff);
        }
    }, [parametre]);

    return (
        <Modal
            open={true}
            onClose={closeModal}
            sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center"
            }}
            aria-labelledby='form-dialog-title'
            closeAfterTransition
        >
            <Fade in={true}>
                <Box
                    sx={{
                        maxWidth: 600,
                        bgcolor: 'background.paper',
                        boxShadow: 24,
                        p: 4,
                        borderRadius: 2,
                    }}
                >
                    <Box
                        display="flex"
                        justifyContent="space-between"
                        alignItems="center"
                    >
                        <Typography variant='h5' fontWeight="bold">Formulaire de parametre</Typography>
                        <Close sx={{ color: "red" }} onClick={closeModal} />
                    </Box>


                    <Box my={2}>
                        <FormControl fullWidth>
                            <InputLabel style={{ color: 'green' }} htmlFor='colonne-select'>Entité</InputLabel>
                            <Select
                                color='success'
                                id='entity-select'
                                InputLabelProps={{
                                    style: { color: 'green' },
                                }}
                                value={entity}
                                onChange={handleEntity}
                                fullWidth
                                label='Entité'
                            >
                                <MenuItem value='construction'>Construction</MenuItem>
                                <MenuItem value='logement'>Logement</MenuItem>
                            </Select>
                        </FormControl>
                    </Box>
                    <Box mb={2}>
                        <Selected
                            colonnes={colonnes}
                            colonne={colonne}
                            handleChange={setColonne}
                        />
                    </Box>

                    <Box mb={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            id='valeur-input'
                            label="Valeur"
                            type='text'
                            fullWidth
                            value={valeur}
                            onChange={(e) => setValeur(e.target.value)}
                        />
                    </Box>

                    <Box mb={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            id='coeff-input'
                            label="Coefficient"
                            type='text'
                            fullWidth
                            value={coeff}
                            onChange={(e) => setCoeff(e.target.value)}
                        />
                    </Box>

                    <Box display='flex' justifyContent='flex-end'>
                        <Button
                            variant='contained'
                            color='success'
                            onClick={send}
                            disabled={isSent}
                        >
                            {isSent && (
                                <i className='fa fa-circle-o-notch fa-spin'></i>
                            )}
                            Enregistrer
                        </Button>
                    </Box>
                </Box>
            </Fade>
        </Modal>
    );
};

export const FormFokontany = ({ fokontany, closeModal }) => {
    const [isSent, setIsSent] = useState(false);
    const [nomfokontany, setNomfokontany] = useState(get1("nomfokontany", fokontany));

    const send = async () => {
        setIsSent(true);
        var data = {
            nomfokontany: nomfokontany,
        };

        if (fokontany != undefined) {
            data["id"] = fokontany["id"];
        }

        await axios.post(
            fokontany == undefined
                ? "api/fokontany/add"
                : "api/fokontany/update",
            data
        )
            .then((res) => {
                closeModal();
                setIsSent(false);
            });
    };

    return (
        <Modal
            open={true}
            onClose={closeModal}
            aria-labelledby='form-dialog-title'
            closeAfterTransition
            sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center"
            }}
        >
            <Fade in={true}>
                <Box
                    sx={{
                        maxWidth: 600,
                        bgcolor: 'background.paper',
                        boxShadow: 24,
                        p: 4,
                        borderRadius: 2,
                    }}
                >
                    <Box
                        display="flex"
                        justifyContent="space-between"
                        alignItems="center"
                    >
                        <Typography variant='h5' fontWeight="bold">Formulaire de parametre</Typography>
                        <Close sx={{ color: "red" }} onClick={closeModal} />
                    </Box>
                    <Box my={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            id='nomfokontany-input'
                            label="Nom fokontany"
                            type='text'
                            fullWidth
                            value={nomfokontany}
                            onChange={(e) => setNomfokontany(e.target.value)}
                        />
                    </Box>

                    <Box display='flex' justifyContent='flex-end'>
                        <Button
                            variant='contained'
                            color='success'
                            onClick={send}
                            disabled={isSent}
                        >
                            {isSent && (
                                <i className='fa fa-circle-o-notch fa-spin'></i>
                            )}
                            Enregistrer
                        </Button>
                    </Box>
                </Box>
            </Fade>
        </Modal>
    );
};

export const FormAgent = ({ agent, closeModal }) => {
    const [isSent, setIsSent] = useState(false);
    const [data, setData] = useState({
        "phone" : "",
        "mdp" : "",
        "nom" : ""
    })

    const handleChange = (key, value) => {
        setData((prevState) => ({
            ...prevState,
            [key]: value
        }))
    }

    const send = async () => {
        setIsSent(true);
        data['type'] = "agent"
        if (agent == undefined) {
            await axios.post(
                "/api/agent",
                data
            )
                .then((res) => {
                    closeModal();
                    setIsSent(false);
                });
        }
        else {
            await axios.put(
                "/api/agent",
                data
            )
                .then((res) => {
                    closeModal();
                    setIsSent(false);
                });
        }

    };

    useEffect(() => {
        if (agent) {
            setData(agent)
        }
    }, [])

    return (
        <Modal
            open={true}
            onClose={closeModal}
            aria-labelledby='form-dialog-title'
            closeAfterTransition
            sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center"
            }}
        >
            <Fade in={true}>
                <Box
                    sx={{
                        maxWidth: 600,
                        bgcolor: 'background.paper',
                        boxShadow: 24,
                        p: 4,
                        borderRadius: 2,
                    }}
                ><Box
                    display="flex"
                    justifyContent="space-between"
                    alignItems="center"
                >
                        <Typography variant='h5' fontWeight="bold">Formulaire de parametre</Typography>
                        <Close sx={{ color: "red" }} onClick={closeModal} />
                    </Box>

                    <Box my={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            label="Telephone"
                            type='text'
                            fullWidth
                            value={data["phone"]}
                            onChange={(e) => handleChange("phone", e.target.value)}
                        />
                    </Box>
                    <Box mb={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            label="Nom"
                            type='text'
                            fullWidth
                            value={data["nom"]}
                            onChange={(e) => handleChange("nom", e.target.value)}
                        />
                    </Box>

                    <Box mb={2}>
                        <TextField
                            InputLabelProps={{
                                style: { color: 'green' },
                            }}
                            color='success'
                            label="Mot de passe"
                            type='text'
                            fullWidth
                            value={data["mdp"]}
                            onChange={(e) => handleChange("mdp", e.target.value)}
                        />
                    </Box>

                    <Box display='flex' justifyContent='flex-end'>
                        <Button
                            variant='contained'
                            color='success'
                            onClick={send}
                            disabled={isSent}
                        >
                            {isSent && (
                                <i className='fa fa-circle-o-notch fa-spin'></i>
                            )}
                            Enregistrer
                        </Button>
                    </Box>
                </Box>
            </Fade>
        </Modal>
    );
};


export const ModalPayment = ({ index, resteApaye, state, setState, numcons, closeModal }) => {
    const [isSent, setIsSent] = useState(false)
    const [payment, setPayment] = useState({
        'montant': "",
        'quittance': ""
    })

    useEffect(() => {
        if (state !== null && state !== undefined) {
            console.log(state)
            setPayment(state)
        }
    }, [state])

    const handlePayment = (key, value) => {
        setPayment((prevState) => ({
            ...prevState,
            [key]: value
        }))
    }

    const send = async () => {
        setIsSent(true)
        let url = "/api/payment/add"
        let message = "Paiement ajouté"
        if (payment["id"] !== undefined && payment["id"] !== null) {
            url = "/api/payment/update"
            message = "Paiement modifié"
        }
        else {
            payment["datePayment"] = getDate()
            payment["timePayment"] = getTime()
        }
        payment["numcons"] = numcons
        await axios.post(url, payment)
            .then((response) => {
                setIsSent(!isSent)
                toast.success(message)
                if (payment["id"] !== undefined || payment["id"] !== null) {
                    setState(index, response.data)
                }
                else {
                    setState(null, response.data)
                }
                closeModal()
            })
    }

    const handleMontant = (value) => {
        if (value == "") {
            handlePayment("montant", "")
        }
        else {
            if (parseInt(value) <= resteApaye) {
                handlePayment("montant", parseInt(value))
                setError("")
            }
            else {
                setError("Montant inférieur ou égale à " + resteApaye + " Ar")
            }
        }

    }

    const [error, setError] = useState("")

    return (
        <Modal
            open={true}
            onClose={closeModal}
            sx={{
                display: "flex",
                justifyContent: "center",
                alignItems: "center"
            }}
            aria-labelledby='form-dialog-title'
            closeAfterTransition
        >
            <Fade in={true}>
                <Box
                    sx={{
                        maxWidth: 600,
                        bgcolor: 'background.paper',
                        boxShadow: 24,
                        p: 4,
                        borderRadius: 2,
                    }}
                >
                    <Box
                        display="flex"
                        justifyContent="space-between"
                        alignItems="center"
                    >
                        <Typography variant='h5' fontWeight="bold">Formulaire de parametre</Typography>
                        <Close sx={{ color: "red" }} onClick={closeModal} />
                    </Box>

                    <Box
                        sx={{
                            my: 2
                        }}
                    >
                        <Box>
                            <TextField
                                InputLabelProps={{
                                    style: { color: 'green' },
                                }}
                                color='success'
                                label="Quittance"
                                type='text'
                                fullWidth
                                value={payment["quittance"]}
                                onChange={(e) => { handlePayment("quittance", e.target.value) }}
                            />
                            <TextField
                                InputLabelProps={{
                                    style: { color: 'green' },
                                }}
                                sx={{
                                    my: 2
                                }}
                                color='success'
                                label="Montant"
                                fullWidth
                                value={payment["montant"]}
                                onChange={(e) => { handleMontant(e.target.value) }}
                            />
                            <Typography htmlFor="">{error !== "" && error}</Typography>
                        </Box>
                        <Box
                            display='flex'
                            justifyContent='flex-end'>
                            <Button
                                variant='contained'
                                color='success'
                                onClick={send}
                                disabled={isSent}
                            >
                                {isSent && (
                                    <i className='fa fa-circle-o-notch fa-spin'></i>
                                )}
                                Enregistrer
                            </Button>
                        </Box>
                    </Box>
                </Box>
            </Fade>

        </Modal>
    );
}
