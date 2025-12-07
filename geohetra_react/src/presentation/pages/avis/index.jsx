import { useCallback, useEffect, useState } from "react";
import axios from "../../../data/api/axios";
import { NavLink, useParams } from "react-router-dom";
import convert from "../../helpers/convertisseur";
import { Box, MenuItem, Pagination, TextField } from "@mui/material";
import { Spinner } from "../../components/loader";
import useFokontany from "presentation/hooks/useFokontany";
import apiUrl from "core/api";

const Tableau = ({ data, id, printed }) => {
  const [typehab, setTypehab] = useState({ HP: 0, HT: 0, AUP: 0, AUT: 0 });
  const date = new Date();

  const adresse = [
    data.adress ? data.adress + ", " : "",
    data.boriboritany ? ", " + data.boriboritany : "",
    data.fokontany.nomfokontany,
  ]
    .join(", ")
    .replaceAll(", ,", "")
    .replaceAll(" , ", ", ")
    .trim();

  function formatter(number) {
    const numberString = String(number);
    let formattedNumber = "";

    for (let i = numberString.length - 1; i >= 0; i--) {
      formattedNumber = numberString[i] + formattedNumber;

      if ((numberString.length - i) % 3 === 0 && i !== 0) {
        formattedNumber = " " + formattedNumber;
      }
    }
    return formattedNumber;
  }

  const handleLogement = useCallback(() => {
    let type = { HP: 0, HT: 0, AUP: 0, AUT: 0 };
    data.logs.forEach((logement) => {
      if (logement.typelog === "Habitat") {
        if (logement.typeoccup === "Propriétaire" || logement.typeoccup === "Occupant gratuit") {
          type.HP += Math.round(logement.impotPerYearWithoutTaux);
        } else {
          type.HT += Math.round(logement.impotPerYearWithoutTaux);
        }
      } else {
        if (logement.typeoccup === "Propriétaire" || logement.typeoccup === "Occupant gratuit") {
          type.AUP += Math.round(logement.impotPerYearWithoutTaux);
        } else {
          type.AUT += Math.round(logement.impotPerYearWithoutTaux);
        }
      }
    });
    setTypehab(type);
  }, [data]);

  useEffect(() => {
    handleLogement();
  }, [handleLogement]);

  return (
    <div className="avis-content" data-printed={printed}>
      <div className="avis">
        <div className="header-avis">
          <div className="hcontent">
            <div className="center fw-bold" style={{ width: 30, height: 35 }}>
              <img
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
                src={`${apiUrl}/api/image/armoiri.jpg`}
                alt=""
              />
            </div>
          </div>
        </div>
        <div className="header-avis">
          <div className="hcontent">
            <div>REPOBLIKAN'I MADAGASIKARA</div>
            <div className="tarigetra">Fitiavana - Tanindrazana - Fandrosoana</div>
            <div className="bold">
              <span className="underline">AVIS D'IMPOSITION</span>
            </div>
          </div>
        </div>
        <div className="header-avis">
          <div className="hcontent">
            {!printed && (
              <div>
                <NavLink to={`/admin/construction/${data.numcons}`} className="btn btn-success">
                  Modifier
                </NavLink>
              </div>
            )}
            <div>
              N° <span className="bold">{data.numfiche} / {date.getFullYear()}</span>
            </div>
            <div>
              Code : <span className="bold">206082101</span>
            </div>
          </div>
        </div>
      </div>

      <div className="header-text">
        Suivant les éléments de recensement en possession du Service, votre imposition au titre de l'année{" "}
        <span className="bold">2023</span>, est arrêtée comme suit :
      </div>

      <div className="flex">
        <table className="table-avis">
          <thead>
            <tr>
              <th className="center">Article</th>
              <th className="center">Nom/Adresse/Emplacement</th>
              <th className="center">I.F.P.B</th>
              <th className="center">Impot à payer</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="padded">
                <div className="center">{data.article && data.article !== "null" ? data.article : ""}</div>
                <div className="center bold">{data.newarticle}</div>
              </td>
              <td className="padded">
                <div>
                  {data.proprietaire
                    ? data.proprietaire.nomprop + " " + (data.proprietaire.prenomprop || "")
                    : "Propriétaire inconnu"}
                </div>
                <div>{adresse}</div>
                <div>AMBALAVAO</div>
                <div>{data.numcons}</div>
              </td>
              <td>
                <div className="padded">
                  <div className="center">Valeur locative</div>
                  <div className="flex">
                    {["HP", "HT", "AUP", "AUT"].map((key) => (
                      <div className="center" key={key}>
                        <div>{key}</div>
                        <div>{formatter(typehab[key])}</div>
                      </div>
                    ))}
                  </div>
                </div>
                <div className="flex-center bordered-top padded">
                  <div className="center">
                    <div>Total IFPB</div>
                    <div className="bold">{formatter(data.impot)}</div>
                  </div>
                </div>
              </td>
              <td>
                <div className="padded">
                  <div className="center">Ar.</div>
                  <div className="center bold">{formatter(data.impot)}</div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div
        className="footer-text"
        style={id !== 4 ? { width: "100%", marginBottom: 5, borderBottom: "2px dashed black" } : {}}
      >
        <div>
          Arrêté le présent avis d'imposition à la somme de : <span style={{ fontWeight: "bolder" }}>{convert(data.impot)} ariary</span>
        </div>
        <div>Date de mise en recouvrement :</div>
        <div style={{ height: 8 }}></div>
      </div>
    </div>
  );
};

const AvisImposition = () => {
  const { id } = useParams();
  const [data, setData] = useState([]);
  const [total, setTotal] = useState(1);

  const fokontany = useFokontany();
  const [selectedFkt, setSelectedFkt] = useState(0);

  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemPerPage] = useState(50);
  const [printed, setPrinted] = useState(false);
  const nbrItemsPerPage = [50, 100, 200];
  const [loading, setLoading] = useState(true);

  const fetch = useCallback(async () => {
    setData([]);
    let url = "";
    if (id === undefined) {
      url = `/api/avis/page=${currentPage}&nbrperpage=${itemsPerPage}&fokontany=${selectedFkt}`;
    } else {
      url = "/api/construction/" + id;
    }
    let response = await axios.get(url);
    setTotal(response.data.total);
    setData(id === undefined ? response.data.data : [response.data.data]);
    setLoading(false);
  }, [currentPage, id, itemsPerPage, selectedFkt]);

  const handlePageChange = (event, newPage) => {
    setCurrentPage(newPage);
  };

  const print = () => {
    setPrinted(true);
  };

  useEffect(() => {
    if (printed) {
      window.print();
      setPrinted(false);
    }
  }, [printed]);

  useEffect(() => {
    fetch();
  }, [fetch]);

  return (
    <div data-printed={printed}>
      {!printed && (
        <Box display="flex" justifyContent="space-between" p={4} mb={5}>
          {id === undefined ? (
            <Box>
              <TextField
                label="Fokontany"
                select
                value={selectedFkt}
                onChange={(e) => setSelectedFkt(e.target.value)}
              >
                <MenuItem key={0} value={0}>
                  Tous
                </MenuItem>
                {fokontany.map((item) => (
                  <MenuItem key={item.id} value={item.id}>
                    {item.nomfokontany}
                  </MenuItem>
                ))}
              </TextField>
              <TextField
                label="Nombre d'avis"
                select
                value={itemsPerPage}
                sx={{ mx: 2 }}
                onChange={(e) => setItemPerPage(e.target.value)}
              >
                {nbrItemsPerPage.map((item, index) => (
                  <MenuItem key={index} value={item}>
                    {item}
                  </MenuItem>
                ))}
              </TextField>
            </Box>
          ) : (
            <Box />
          )}
          <button onClick={print} className="btn btn-primary">
            <i className="fa fa-print"></i> Imprimer
          </button>
        </Box>
      )}

      <div className={!printed ? "container" : ""}>
        {loading ? (
          <Spinner />
        ) : (
          Array(Math.ceil((data?.length || 0) / 5))
            .fill()
            .map((_, groupIndex) => (
              <div
                className="page"
                key={groupIndex}
                style={
                  !printed
                    ? { boxShadow: "0 0 5px rgba(159, 159, 159, 0.3)", backgroundColor: "white", padding: "20px" }
                    : { padding: 0, boxShadow: "none" }
                }
              >
                {data
                  .slice(groupIndex * 5, groupIndex * 5 + 5)
                  .map((value, index) => (
                    <Tableau key={`${groupIndex}-${index}`} printed={printed} data={value} id={index} />
                  ))}
              </div>
            ))
        )}
      </div>

      <Box sx={{ display: "flex", justifyContent: "center" }} my={2}>
        {!printed && !loading && (
          <Pagination
            count={Math.ceil(total / itemsPerPage)}
            page={currentPage}
            onChange={handlePageChange}
            color="success"
          />
        )}
      </Box>
    </div>
  );
};

export default AvisImposition;
