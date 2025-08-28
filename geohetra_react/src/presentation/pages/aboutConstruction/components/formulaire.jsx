import { Box, Button, Card, CardContent, CardHeader, Typography } from '@mui/material';
import { Folder } from '@mui/icons-material';
import { useEffect, useState } from 'react';
import { getDate } from 'presentation/helpers/date';
import ConstructionService from 'domain/services/constructionService';
import { toast } from 'react-toastify';


const Formulaire = ({ data, file, parameter, url, id, index, title, col, refresh }) => {
    const [state, setState] = useState(null)
    const [field, setField] = useState(false)

    const keys = Object.keys(parameter)
    const handleState = (key, value) => {
        setState((prevState) => ({
            ...prevState,
            [key]: value
        }))
    }

    const handleSend = async () => {
        if (field) {
            setField(false)
            if (data[id] == null || data[id] == undefined) {
                state[id] = getDate()
                state["typecons"] = "Imposable"
                await ConstructionService.post("/api" + url, state)
                    .then(() => {
                        setField(false)
                        toast.success(title + " ajouté avec succés")
                        setState((prevState) => ({
                            ...prevState,
                            [id]: state[id]
                        }))
                        if (title == "Construction") {
                            refresh(state[id])
                        }
                    })
            }
            else {
                state[id] = data[id]
                let form = new FormData()
                if (title == "Construction") {
                    form.append("image", file)
                    form.append("data", JSON.stringify(state))
                    await ConstructionService.post("/api/update/construction", form)
                        .then(() => {
                            toast.success(title + " modifié avec succés")
                        })
                }
                else {
                    await ConstructionService.put("/api" + url, state)
                        .then(() => {
                            toast.success(title + " modifié avec succés")
                        })
                }


            }
        }
        else {
            setField(true)
        }
    }

    const handleCheck = (key, name) => {
        let data = state[key].split(", ")
        if (!data.includes(name)) {
            data.push(name)
        }
        else {
            data = data.filter((value) => value != name)
        }
        handleState(key, data.filter((value) => value != "").join(", "))
    }

    const CheckBoxOption = ({ k, data, name }) => {
        const [checked, setChecked] = useState(null)
        const handleChange = () => {
            handleCheck(k, name)
            setChecked(!checked)
        }

        const verify = () => {
            if (!data.includes(name)) {
                setChecked(false)
            }
            else {
                setChecked(true)
            }
        }

        useEffect(() => {
            if (checked == null) {
                verify()
            }
        }, [checked])

        return (
            <input type="checkbox" checked={checked} onClick={handleChange} />
        )
    }

    const handleData = () => {
        let state = {}
        Object.keys(data).forEach((value) => {
            state[value] = data[value]
        })
        setState(state)
    }

    const switcher = (key) => {
        switch (parameter[key].type) {
            case "select":
                if (typeof parameter[key].options[0] == "string") {
                    return (
                        <select className='form-select' value={state[key]} onChange={(e) => handleState(key, e.target.value)}>
                            {parameter[key].options.map((value, key) => <option key={key} value={value}>{value}</option>)}
                        </select>
                    )
                }
                else {
                    return (
                        <select className='form-select' value={state[key]} onChange={(e) => handleState(key, e.target.value)}>
                            {parameter[key].options.map((elt, key) => <option key={key} value={elt.id}>{elt.value}</option>)}
                        </select>
                    )
                }
            case "radio":
                return (
                    <>
                        {
                            parameter[key].options.map((value, index) => (
                                <div>
                                    <input key={index} type="radio" checked={value == state[key] ? true : false} name='wc' onClick={(e) => handleState(key, value)} />
                                    <span>{value}</span>
                                </div>)
                            )
                        }
                    </>
                )
            case "checkbox":
                return (
                    <div>
                        {
                            state[key] !== null && parameter[key].options.map((value, k) =>
                            (
                                <div key={k}>
                                    <CheckBoxOption k={key} data={state[key].split(", ")} name={value} /> <label> {value} </label>
                                </div>
                            )
                            )
                        }
                    </div>
                )
            default:
                return <input className='form-control' value={state[key]} onChange={(e) => handleState(key, e.target.value)} />
        }
    }

    useEffect(() => {
        if (state == null) {
            handleData()
        }
    }, [state])

    useEffect(() => {
        if (data[id] == undefined) {
            setField(true)
        }
    }, [data])

    const getTitle = () => {
        return title + ' ' + (title == "Logement" ? (index + 1) : "")
    }

    return (
        <Card
            sx={{
                mb: 5,
                p: 2
            }}
            elevation={0}
        >
            {
                state != null &&
                <>
                    <CardHeader
                        title={getTitle()}
                        action={
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                {(title == "Logement" && data != null && data[id] != undefined) && <Button color="error" variant='contained' sx={{ mr: 2 }} >Supprimer</Button>}
                                <Button color='success' variant='contained' onClick={handleSend} >{field ? "Enregistrer" : "Modifier"}</Button>
                            </div>
                        }
                    />
                    <CardContent>
                        <div className="row">
                            {field == true ?
                                keys.map((key, index) => (
                                    <div key={index} className={'col-md-' + col}>
                                        <Typography>{parameter[key]["title"]}</Typography>
                                        {switcher(key)}
                                    </div>
                                )) :
                                keys.map((key, index) => (
                                    <div key={index} className={'col-md-' + col}>
                                        <Box
                                            display="flex"
                                            justifyContent="flex-start"
                                            alignItems="center"
                                        >
                                            <Folder sx={{ color: "#ECECEC", mr: 1 }} />
                                            <Typography fontWeight="bold"> {parameter[key]["title"]}</Typography>
                                        </Box>
                                        <Typography sx={{ pl: 4, pb: 2, color: state[key] == "Inconnu" ? "grey" : "black" }}>{(state[key] == "Inconnu" || state[key] == "" || state[key] == null) ? "Inconnu" : state[key]}</Typography>
                                    </div>
                                ))
                            }
                        </div>
                    </CardContent>
                </>
            }
        </Card>
    )
}

export default Formulaire
