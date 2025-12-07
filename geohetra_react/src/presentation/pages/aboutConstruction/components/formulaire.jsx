import { Box, Button, Card, CardContent, CardHeader, Typography } from '@mui/material';
import { Folder } from '@mui/icons-material';
import { useEffect, useMemo, useState } from 'react';
import { getDate } from 'presentation/helpers/date';
import ConstructionService from 'domain/services/constructionService';
import { toast } from 'react-toastify';

const Formulaire = ({ data, file, parameter, url, id, index, title, col, refresh }) => {
  const [state, setState] = useState(null);
  const [field, setField] = useState(false);

  const keys = Object.keys(parameter);

  // Mise à jour de state
  const handleState = (key, value) => {
    setState((prevState) => ({
      ...prevState,
      [key]: value,
    }));
  };

  const handleSend = async () => {
    if (field) {
      setField(false);
      if (data[id] === null || data[id] === undefined) {
        state[id] = getDate();
        state["typecons"] = "Imposable";
        await ConstructionService.post("/api" + url, state);
        toast.success(title + " ajouté avec succès");
        setState((prevState) => ({ ...prevState, [id]: state[id] }));
        if (title === "Construction") refresh(state[id]);
      } else {
        state[id] = data[id];
        let form = new FormData();
        if (title === "Construction") {
          form.append("image", file);
          form.append("data", JSON.stringify(state));
          await ConstructionService.post("/api/update/construction", form);
          toast.success(title + " modifié avec succès");
        } else {
          await ConstructionService.put("/api" + url, state);
          toast.success(title + " modifié avec succès");
        }
      }
    } else {
      setField(true);
    }
  };

  const handleCheck = (key, name) => {
    let dataArray = state[key].split(", ");
    if (!dataArray.includes(name)) dataArray.push(name);
    else dataArray = dataArray.filter((value) => value !== name);
    handleState(key, dataArray.filter((v) => v !== "").join(", "));
  };

  // ✅ CheckBoxOption corrigé
  const CheckBoxOption = ({ k, data, name }) => {
    const [checked, setChecked] = useState(false);

    useEffect(() => {
      setChecked(data.includes(name));
    }, [data, name]);

    const handleChange = () => {
      handleCheck(k, name);
      setChecked((prev) => !prev);
    };

    return <input type="checkbox" checked={checked} onChange={handleChange} />;
  };

  // Initialiser state avec les données existantes
  const handleData = useMemo(() => {
    const initialState = {};
    Object.keys(data).forEach((key) => {
      initialState[key] = data[key];
    });
    setState(initialState);
  }, [data]);

  const switcher = (key) => {
    switch (parameter[key].type) {
      case "select":
        return (
          <select
            className="form-select"
            value={state[key] ?? ""}
            onChange={(e) => handleState(key, e.target.value)}
          >
            {parameter[key].options.map((opt, idx) => (
              <option key={opt.id ?? idx} value={typeof opt === "string" ? opt : opt.id}>
                {typeof opt === "string" ? opt : opt.value}
              </option>
            ))}
          </select>
        );

      case "radio":
        return (
          <>
            {parameter[key].options.map((value, idx) => (
              <div key={idx}>
                <input
                  type="radio"
                  checked={value === state[key]}
                  name={`radio-${key}`}
                  onChange={() => handleState(key, value)}
                />
                <span>{value}</span>
              </div>
            ))}
          </>
        );

      case "checkbox":
        return (
          <div>
            {state[key] !== null &&
              parameter[key].options.map((value, k) => (
                <div key={k}>
                  <CheckBoxOption k={key} data={state[key].split(", ")} name={value} />{" "}
                  <label>{value}</label>
                </div>
              ))}
          </div>
        );

      default:
        return (
          <input
            className="form-control"
            value={state[key] ?? ""}
            onChange={(e) => handleState(key, e.target.value)}
          />
        );
    }
  };

  useEffect(() => {
    if (state === null) handleData();
  }, [state, handleData]);

  useEffect(() => {
    if (data[id] === undefined) setField(true);
  }, [data, id]);

  const getTitle = () => title + " " + (title === "Logement" ? index + 1 : "");

  return (
    <Card sx={{ mb: 5, p: 2 }} elevation={0}>
      {state !== null && (
        <>
          <CardHeader
            title={getTitle()}
            action={
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                {title === "Logement" && data !== null && data[id] !== undefined && (
                  <Button color="error" variant="contained" sx={{ mr: 2 }}>
                    Supprimer
                  </Button>
                )}
                <Button color="success" variant="contained" onClick={handleSend}>
                  {field ? "Enregistrer" : "Modifier"}
                </Button>
              </div>
            }
          />
          <CardContent>
            <div className="row">
              {keys.map((key, index) => (
                <div key={index} className={"col-md-" + col}>
                  {field ? (
                    <>
                      <Typography>{parameter[key]["title"]}</Typography>
                      {switcher(key)}
                    </>
                  ) : (
                    <>
                      <Box display="flex" alignItems="center">
                        <Folder sx={{ color: "#ECECEC", mr: 1 }} />
                        <Typography fontWeight="bold">{parameter[key]["title"]}</Typography>
                      </Box>
                      <Typography sx={{ pl: 4, pb: 2, color: !state[key] || state[key] === "Inconnu" ? "grey" : "black" }}>
                        {state[key] || "Inconnu"}
                      </Typography>
                    </>
                  )}
                </div>
              ))}
            </div>
          </CardContent>
        </>
      )}
    </Card>
  );
};

export default Formulaire;
