import { useState } from "react";
import { useEffect } from "react";
import axios from "../../../data/api/axios";
import { Table } from "../../components/table";
import { FormParametre } from "../../components/modal/modal";
import { Box } from "@mui/material";


const Coefficient = () => {
    const [data, setData] = useState([])
    const [search, setSearch] = useState("")
    const title = ["Table", "Colonne", "Valeur", "Coefficient"]
    const keys = ["entity", "designation", "valeur", "coeff"]
    const [selected, setSelected] = useState(null)
    const [modal, setModal] = useState(false)

    const handleSelected = (data) => {
        setSelected(data)
        setModal(!modal)
    }

    const handleModal = () => {
        setSelected(undefined)
        setModal(!modal)
    }

    const deleteSelected = async (data) => {
        await axios.get("api/parametre/delete/" + data.id)
    }

    const action = (data) => {
        return (
            <td style={{ borderBottom : "1px solid #DFDFDF"}}>
                <a onClick={() => { handleSelected(data) }} className="btn btn-success"><i className="fa fa-pencil"></i></a>
                <a onClick={() => { deleteSelected(data) }} className="btn btn-danger"><i className="fa fa-trash"></i></a>
            </td>
        )
    }

    const fetch = async () => {
        let response = await axios.get("api/parametre")
        setData(response.data)
    }

    useEffect(() => {
        fetch()
    }, [])
    return (
        <>
            {modal && <FormParametre parametre={selected} closeModal={handleModal} />}
            <Box
                p={4}
                mb={10}
            >
                <Table
                    rows={data}
                    search={search}
                    title={title}
                    add={() => {
                        setSelected()
                        setModal(true)
                    }}
                    keys={keys}
                    colaction={action}
                />
            </Box>
        </>
    )
}

export default Coefficient