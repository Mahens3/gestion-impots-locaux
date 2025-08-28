import { Box, Grid, Stack, Skeleton } from "@mui/material"


const CardSkeleton = () => {
    return (
        <Grid item xs={12} sm={12} md={4} lg={3}>
            <Stack>
                <Skeleton
                    variant="rectangular"
                    height={180}
                    width="100%"
                    animation="wave"
                />

            </Stack>

            <Box
                display="flex"
                justifyContent="flex-start"
                alignItems="center"
            >
                <Skeleton
                    variant="circular"
                    animation="wave"
                    width={40}
                    height={40}
                />
                <Box
                    width="calc(100% - 40px)"
                >
                    <Skeleton
                        variant="text"
                        animation="wave"
                    />
                    <Skeleton
                        variant="text"
                        animation="wave"
                    />
                </Box>
            </Box>
        </Grid>
    )
}

export default CardSkeleton