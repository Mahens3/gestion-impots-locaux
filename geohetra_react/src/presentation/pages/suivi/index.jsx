import { useMemo } from 'react'
import useSuivi from './hook/useSuivi'
import useFokontany from 'presentation/hooks/useFokontany'
import { Spinner } from 'presentation/components/loader'

const Suivi = () => {
    const { isLoading, selectedFkt, setSelectedFkt, data } = useSuivi()
    const fokontany = useFokontany()

    const print = () => {
        window.print()
    }

    const nomfokontany = useMemo(() => {
        const value = fokontany.filter((value) => value.id === selectedFkt)
        return value[0]!==undefined ? value[0].nomfokontany : ""

    }, [fokontany, selectedFkt])

    return (
        <div>
            <div className='m-4'>
                <div className='justify-content-between header-action'>
                    <div className='mb-3'>
                        <label htmlFor="">Fokontany</label>
                        <select
                            value={selectedFkt}
                            onChange={(e) => {
                                setSelectedFkt(e.target.value)
                            }}
                            className='form-control'
                        >
                            {
                                fokontany.map((item, key) =>
                                    <option key={key} value={item.id}>{item.nomfokontany}</option>
                                )
                            }
                        </select>
                    </div>
                    <div>
                        <button onClick={print} className='btn btn-primary'><i className='fa fa-print'></i> Imprimer</button>
                    </div>
                </div>
                <div className='justify-content-between header-print'>
                    <div className='title fw-bold'>
                        {fokontany.length > 0 && nomfokontany}
                    </div>
                    <div className='title fw-bold'>
                        Total: {data.total} Ar
                    </div>
                </div>

                <div>
                    {
                        (fokontany.length === 0 && isLoading) ? <Spinner /> :

                            <table className='table-primary'>
                                <thead>
                                    <th>Article</th>
                                    <th>Propriétaire</th>
                                    <th>Adresse</th>
                                    <th>Boriboritany</th>
                                    <th>IFPB</th>
                                    <th>Paiement</th>
                                </thead>
                                <tbody>
                                    {
                                        data.constructions.map(
                                            (construction, key) => (
                                                <tr key={key}>
                                                    <td>{construction.article}</td>
                                                    <td>{construction.proprietaire}</td>
                                                    <td>{construction.adresse}</td>
                                                    <td>{construction.boriboritany}</td>
                                                    <td className='nowrap'>{construction.ifpb}</td>
                                                    <td className='nowrap'>{construction.payment}</td>
                                                </tr>
                                            )
                                        )
                                    }
                                </tbody>
                            </table>
                    }
                </div>
            </div>
        </div>
    )
}

export default Suivi