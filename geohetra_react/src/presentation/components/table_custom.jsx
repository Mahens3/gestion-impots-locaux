import { AES, SHA256 } from 'crypto-js';
import React, { useState, useEffect, useCallback } from 'react';
import { NavLink } from 'react-router-dom';
import { formatter } from '../helpers/convertisseur';

import ImageGallery from "react-image-gallery";
import axios from '../../data/api/axios';
import { createPortal } from 'react-dom';
import { Modal, ModalFooter, ModalBody, ModalHeader, ModalTitle } from 'react-bootstrap';
import { ToastContainer, toast } from 'react-toastify';

const CustomTable = ({ columns, data, impot, setData }) => {
    const [rows, setRows] = useState([])
    const [searchQueries, setSearchQueries] = useState({});
    const [image, setImage] = useState(null)
    const [printable, setPrintable] = useState({})
    const [checkedAll, setCheckedAll] = useState(true)

    useEffect(() => {
        setRows(data)
    }, [data])

    const [query, setQuery] = useState({
        "niveau": {
            "sup": 0,
            "inf": 0
        },
        "surface": {
            "sup": 0,
            "inf": 0
        },
        "impot": {
            "sup": 0,
            "inf": 0
        }
    })

    const [selected, setSelected] = useState("niveau")
    const handleSelectedOpt = (e) => {
        setSelected(e.target.value)
    }

    const handleChangeValue = (key, value) => {
        let object = query[selected]
        object[key] = parseInt(value)
        setQuery((prevState) => ({
            ...prevState,
            [selected]: object
        }))
    }

    const handleSearch = useCallback(
        (columnId, value) => {
            setSearchQueries((prevQueries) => ({
                ...prevQueries,
                [columnId]: value,
            }));

        }, []);

    const filteredData = rows.filter((row) =>
        columns.every((column) =>
            String(row[column.nomCol])
                .toLowerCase()
                .includes((searchQueries[column.id] || '').toLowerCase())

        )
    );

    // Pagination
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(20);

    const [isModalOpen, setIsModalOpen] = useState(false);
    const handleItemsPerPageChange = useCallback((e) => {
        setItemsPerPage(Number(e.target.value));
        setPrintable({})
        setCurrentPage(1);
    }, []);

    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentItems = filteredData.slice(indexOfFirstItem, indexOfLastItem);
    const totalPages = Math.ceil(filteredData.length / itemsPerPage);
    const maxPageLinks = 5; // Définissez le nombre maximal de liens de page à afficher à la fois

    const handleCkeck = (value) => {
        setPrintable((prevState) => ({
            ...prevState,
            [value]: !printable[value]
        }))
    }

    const handleCheckAll = () => {
        var newObject = {}
        Object.keys(printable).forEach((value) => {
            newObject[value] = !checkedAll
        })
        setPrintable(newObject)
        setCheckedAll(!checkedAll)
    }

    const handleModal = () => {
        setIsModalOpen(!isModalOpen);
    };

    const handleQuery = () => {
        let row = []
        console.log(query)
        data.forEach((value) => {
            if (verif("niveau", value) == true && verif("surface", value) == true && verif("impot", value) == true) {
                row.push(value)
            }
        })
        setRows(row)
        setModal(false)
    }

    const verif = (key, data) => {
        var bool = false
        if (query[key]["inf"] <= data[key]) {
    
            if (query[key]["sup"] == 0) {
                bool = true
            }
            else {
                if (query[key]["sup"] > query[key]["inf"] && query[key]["sup"] > data[key]) {
                    bool = true
                }
                else {
                    bool = false
                }
            }
        }


        return bool
    }

    const handleSelected = async (data) => {
        let ext = data.image.split(".")
        await axios.get("/api/construction/base64/" + data.image)
            .then((response) => {
                setImage(
                    [{ original: "data:image/" + ext[ext.length - 1] + ";base64," + response.data }]
                )
                handleModal()
            })
    }

    const renderRows = useCallback(() => {
        return currentItems.map((row, index) => (
            <tr key={row.id}>
                <td>
                    <div className="flex">
                        <input key={index} type="checkbox" checked={printable[row.numcons]} onChange={() => { handleCkeck(row.numcons) }} />
                        <NavLink to={'/construction/' + row.numcons} className="btn btn-success"><i className="fa fa-pencil"></i></NavLink>
                    </div>
                </td>
                <td>
                    <img style={{ width: 50, height: 50 }} src={"http://localhost:8000/api/image/" + row.image} onClick={() => { handleSelected(row) }} />
                </td>
                {columns.map((column) => <td key={column.id}>{column.nomCol == "impot" ? formatter(row[column.nomCol]) : row[column.nomCol]}</td>

                )}
            </tr>
        ));
    }, [columns, rows, currentItems]);

    const paginate = useCallback(
        (pageNumber) => {
            const validPageNumber = Math.max(1, Math.min(pageNumber, totalPages));
            setCurrentPage(validPageNumber);

        },
        [filteredData, itemsPerPage, totalPages]
    );

    const [modal, setModal] = useState(false)

    useEffect(() => {
        if (JSON.stringify(printable) == '{}') {
            let object = {}
            currentItems.forEach((value) => {
                object[value.numcons] = true
            })

            let hashPrev = SHA256(JSON.stringify(printable))
            let hashNext = SHA256(JSON.stringify(object))

            if (hashNext.toString() != hashPrev.toString()) {
                setPrintable(object)
            }
        }

    }, [currentItems])

    const handleNiveau =  async () => {
        await axios.post("api/update/niveau", {"niveau" : niveau, "constructions" : constructions})
        .then((response) => {
            toast.success("Construction modifié")
            setModalModif(false)
            setConstructions([])
        })
    }

    const handleConstruction = (key, value) => {
        setSelectedConstruction((prevState) => ({
            ...prevState,
            [key] : value
        }))
    }

    const reinit = () => {
        setRows(data)
    }

    const [selectedConstruction, setSelectedConstruction] = useState({"numcons" : "", "niveau" : 0})
    const [modalModif, setModalModif] = useState(false)

    const [constructions, setConstructions] = useState([])
    const handleArrayConstruction = (data) => {
        if( constructions.indexOf(data.numcons)>=0){
            setConstructions(constructions.filter((numcons) => numcons!=data.numcons ))
        }
        else{
            setConstructions([...constructions, data.numcons])
        }
    }

    const [niveau, setNiveau] = useState()

    return (
        <div className="container-fluid">
            <Modal show={modalModif}>
                <ModalHeader>
                    <div>
                        {selectedConstruction.proprietaire}
                    </div>
                    <button className='close' onClick={() => { setModalModif(false) }}>X</button>
                </ModalHeader>
                <ModalBody>
                    <label htmlFor="">Niveau</label>
                    <input className='form-control' type="number" value={niveau} onChange={(e) => { setNiveau(e.target.value) }} />
                </ModalBody>
                <ModalFooter>
                    <button className='btn btn-primary' onClick={handleNiveau}>Enregistrer</button>
                </ModalFooter>
            </Modal>
            <ToastContainer position='top-right'/>
            {isModalOpen && (
                createPortal(
                    <div className="modal-img">

                        <div className="modal-content">
                            <div className="modal-img-header">
                                <span className="modal-close" onClick={handleModal}>
                                    &times;
                                </span>
                            </div>
                            <ImageGallery
                                items={image}
                                useBrowserFullscreen={false}
                                thumbnailPosition="bottom"
                                showPlayButton={false}
                                showFullscreenButton={false}
                            />
                        </div>
                    </div>
                    , document.body)

            )}

            {

                <Modal className='modal fade' show={modal} >
                    <ModalHeader style={{ width: "100%", height: "100%" }} className='justify-content-between'>
                        <ModalTitle>
                            Modal Requête
                        </ModalTitle>
                        <button onClick={() => { setModal(false) }} className='btn btn-rounded btn-danger'>&times;</button>
                    </ModalHeader>
                    <ModalBody style={{ width: "100%", height: "100%" }}>
                        <div className='my-2'>
                            <label htmlFor="">Colonne</label>
                            <select onChange={handleSelectedOpt} value={selected} className='form-select'>
                                <option value="niveau">niveau</option>
                                <option value="surface">surface</option>
                                <option value="impot">impot</option>
                            </select>
                        </div>

                        <div className='flex'>
                            <input type="number" value={query[selected]["inf"]} onChange={(e) => { handleChangeValue("inf", e.target.value) }} className='form-control' placeholder='Inferieur' />
                            <input type="number" value={query[selected]["sup"]} onChange={(e) => { handleChangeValue("sup", e.target.value) }} className='form-control' placeholder='Superieur' />
                        </div>

                    </ModalBody>
                    <ModalFooter style={{ width: "100%", height: "100%" }}>
                        <div >
                            <button onClick={handleQuery} className='btn btn-primary'>Executer</button>
                        </div>
                    </ModalFooter>
                </Modal>
            }
            <div className="card">
                <div className="card-header">
                    <div>
                        <NavLink to={"/construction/avis/" + AES.encrypt(JSON.stringify(printable), "1 f$ert").toString().replaceAll("/", "_")} className="btn btn-success">
                            <i className="fa fa-file"></i>  Générer avis
                        </NavLink>
                        <NavLink to={"/construction/0"} className="btn btn-primary">
                            <i className="fa fa-plus"></i>  Nouveau
                        </NavLink>
                        <button className='btn btn-success' onClick={() => { setModalModif(true) }}>Ouvrir Modal</button>
                    </div>
                    <div>
                        <button onClick={reinit} className='btn btn-primary'>Reinitialiser la liste</button>
                        <button onClick={() => { setModal(true) }} className='btn btn-primary'>Requête</button>
                    </div>
                </div>
                <div className="card-body">
                    <div className="flex">
                        <div className="flex">
                            <label htmlFor="itemsPerPageSelect" className="form-label mx-2 mt-1">
                                Lignes:
                            </label>
                            <select
                                id="itemsPerPageSelect"
                                className="form-select"
                                value={itemsPerPage}
                                onChange={handleItemsPerPageChange}
                            >
                                <option value="20">20/pagination </option>
                                <option value="40">40/pagination </option>
                                <option value="50">50/pagination </option>
                                <option value="100">100/pagination </option>
                                <option value="100">150/pagination </option>
                                <option value="100">200/pagination </option>
                            </select>
                        </div>
                        <div className='fw-bold'>
                            <div>
                                {formatter(impot)} Ariary
                            </div>
                            <div>
                                {filteredData.length} Construction(s)
                            </div>
                        </div>
                    </div>
                    <div style={{ maxWidth: '99%', minHeight: '50vh', overflow: 'auto' }}>
                        <table className="table table-striped">
                            <thead>
                                <th className='fw-bold '>

                                    <div>
                                        <input className='mx-2' type="checkbox" checked={checkedAll} onChange={handleCheckAll} />
                                        <span>Actions</span>
                                    </div>
                                </th>

                                <th className='fw-bold'>
                                    <div>
                                        <span>Photo</span>
                                    </div>
                                </th>
                                {
                                    columns.map((column) => <th key={column.id}>
                                        <div className='align-items-center'>
                                            <span className='fw-bold'>{column.nomCol}</span>
                                            <input
                                                type="text"
                                                value={searchQueries[column.id] || ''}
                                                placeholder='Recherche'
                                                onChange={(e) => handleSearch(column.id, e.target.value)}
                                                className="form-control"
                                            />
                                        </div>
                                    </th>
                                    )
                                }
                            </thead>
                            <tbody>{renderRows()}</tbody>
                            <tfoot>
                                <th className='fw-bold '>
                                    <div>
                                        <input className='mx-2' type="checkbox" checked={checkedAll} onChange={handleCheckAll} />
                                        <span>Actions</span>
                                    </div>
                                </th>
                                <th className='fw-bold'>
                                    <div>
                                        <span>Modifier</span>
                                    </div>
                                </th>
                                <th className='fw-bold'>
                                    <div>
                                        <span>Photo</span>
                                    </div>
                                </th>
                                {
                                    columns.map((column) => <th key={column.id}>
                                        <div className='align-items-center'>
                                            <span className='fw-bold'>{column.nomCol}</span>
                                            <input
                                                type="text"
                                                value={searchQueries[column.id] || ''}
                                                placeholder='Recherche'
                                                onChange={(e) => handleSearch(column.id, e.target.value)}
                                                className="form-control"
                                            />
                                        </div>
                                    </th>
                                    )
                                }
                            </tfoot>
                        </table>
                    </div>
                </div>
                <div className="card-footer flex justify-content-between align-items-center">
                    <div>
                        <NavLink to={"/construction/avis/" + AES.encrypt(JSON.stringify(printable), "1 f$ert").toString().replaceAll("/", "_")} className="btn btn-success">
                            <i className="fa fa-file"></i>  Générer avis
                        </NavLink>
                        <NavLink to={"/construction/0"} className="btn btn-primary">
                            <i className="fa fa-plus"></i>  Nouveau
                        </NavLink>

                        <button className='btn btn-success' onClick={() => { setModalModif(true) }}>Ouvrir Modal</button>
                    </div>
                    <nav>
                        <ul className="pagination">
                            <li
                                className={`page-item ${currentPage === 1 ? 'disabled' : ''}`}
                                onClick={() => paginate(currentPage - 1)}
                            >
                                <span className="page-link">Précédent</span>
                            </li>
                            {Array.from({ length: totalPages }).map((_, index) => {
                                const page = index + 1;
                                const isCurrentPage = currentPage === page;
                                const isWithinRange =
                                    page <= currentPage + Math.floor(maxPageLinks / 2) &&
                                    page >= currentPage - Math.floor(maxPageLinks / 2);
                                const isFirstPage = index === 0;
                                const isLastPage = index === totalPages - 1;

                                if (
                                    isFirstPage ||
                                    isLastPage ||
                                    isCurrentPage ||
                                    isWithinRange ||
                                    totalPages <= maxPageLinks
                                ) {
                                    return (
                                        <li
                                            key={index}
                                            className={`page-item ${isCurrentPage ? 'active' : ''}`}
                                            onClick={() => paginate(page)}
                                        >
                                            <span className="page-link">{page}</span>
                                        </li>
                                    );
                                }

                                return null;
                            })}
                            <li
                                className={`page-item ${currentPage === totalPages ? 'disabled' : ''}`}
                                onClick={() => paginate(currentPage + 1)}
                            >
                                <span className="page-link">Suivant</span>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>
    );
};

export default CustomTable;
