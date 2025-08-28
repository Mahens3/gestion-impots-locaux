import { Box, Card, CardContent, CardHeader, Typography } from '@mui/material';
import { Folder } from '@mui/icons-material';
import { useEffect, useState } from 'react';


const CardItem = ({ data, parameter, index, title, col }) => {
    const [state, setState] = useState(null)

    const keys = Object.keys(parameter)

    const handleData = () => {
        let state = {}
        Object.keys(data).forEach((value) => {
            state[value] = data[value]
        })
        setState(state)
    }

    useEffect(() => {
        if (state == null) {
            handleData()
        }
    }, [state])

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
                        action={null}
                    />
                    <CardContent>
                        <div className="row">
                            {
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
                                ))}
                        </div>
                    </CardContent>
                </>
            }
        </Card>
    )
}

export default CardItem
