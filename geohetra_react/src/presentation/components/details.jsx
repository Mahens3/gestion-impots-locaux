import { Box, CardHeader, Typography, Card, CardContent } from '@mui/material';


const Detail = ({ data }) => {
    const keys = { "typequart": "Type quartier", "etatmur": "Etat du mur", "access": "Accéssibilité" }
    const logements = data.map((logement) => {
        let details = []
        if (logement.details != undefined) {
            logement.details.forEach((detail) => {
                details.push(detail)
            })
        }
        return details
    })

    const getDetail = (value) => {
        let array = value.split(": ")
        return (
            <Box
                display="flex"
                justifyContent="flex-start"
            >
                <Typography fontWeight='bold'>{keys[array[0]] !== undefined ? keys[array[0]] : array[0]}</Typography>:
                <Typography>{array[1]}</Typography>
            </Box>
        )
    }
    return (
        <Box className="container">
            <Box className='row mt-5'>
                {
                    logements.filter((item) => item.length > 0).map(
                        (logement, index) =>
                            <div key={index} className="col-md-6">
                                <Card
                                    elevation={0}
                                >
                                    <CardHeader
                                        title={"Logement n°" + (index + 1)}
                                    />
                                    <CardContent>
                                        {
                                            logement.map((detail, index) => <Box key={index} >{getDetail(detail)}</Box>)
                                        }
                                    </CardContent>
                                </Card>
                            </div>
                    )
                }
            </Box>
        </Box>
    )
}

export default Detail