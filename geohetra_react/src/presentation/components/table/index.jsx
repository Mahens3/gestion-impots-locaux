import React, { useState } from 'react';
import {
    TableContainer,
    Table as MuiTable,
    TableHead,
    TableBody,
    TableRow,
    TableCell,
    Paper,
    InputAdornment,
    TextField,
    Box,
    Typography,
    Pagination,
    Button,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';

export const Table = ({ colaction, rows, withIndex = false, add, keys, title }) => {
    const [page, setPage] = useState(1)
    const [rowsPerPage, setRowsPerPage] = useState(24);
    const [search, setSearch] = useState('');

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };


    const Cols = ({ keys, contents }) => {
        return keys.map((key, i) => (
            <TableCell key={i}>{contents[key]}</TableCell>
        ));
    };

    const Rows = ({ rows, keys, search }) => {
        return rows
            .filter((elt) =>
                keys.some(
                    (key) =>
                        (elt[key] || "")
                            .toString()
                            .toLowerCase()
                            .includes(search.toLowerCase())
                )
            )
            .map((item, index) => (
                <TableRow
                    key={index}
                >
                    { colaction!==undefined && ( withIndex ? colaction(index, item) : colaction(item) ) }
                    <Cols contents={item} keys={keys} />
                </TableRow>
            ));
    };


    const Th = () => {
        return title.map((elt, key) => (
            <TableCell className='center' key={key}>
                {elt}
            </TableCell>
        ));
    };

    return (
        <Paper
            elevation={0}
            sx={{
                p: 3
            }}
        >
            <Box
                display='flex'
                justifyContent='space-between'
                alignItems='center'
            >
                <Typography>{rows.length} Elements</Typography>
                <Box>
                    <TextField
                        placeholder='Rechercher'
                        variant='outlined'
                        size='small'
                        color='success'
                        sx={{
                            mx: 2
                        }}
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        InputProps={{
                            startAdornment: (
                                <InputAdornment position='start'>
                                    <SearchIcon />
                                </InputAdornment>
                            ),
                        }}
                    />
                    <Button
                        variant='contained'
                        color='success'
                        onClick={() => {
                            add()
                        }}
                    >
                        Nouveau
                    </Button>
                </Box>
            </Box>
            <TableContainer>
                <MuiTable>
                    <TableHead>
                        <TableRow>
                            {colaction !== undefined && <TableCell>Action</TableCell>}
                            <Th />
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        <Rows
                            rows={rows.slice(
                                (page - 1) * rowsPerPage,
                                (page - 1) * rowsPerPage + rowsPerPage
                            )}
                            withIndex={withIndex}
                            keys={keys}
                            search={search}
                        />
                    </TableBody>
                </MuiTable>
            </TableContainer>

            <Box
                display='flex'
                justifyContent='center'
                alignItems='center'
                p={2}
            >
                <Pagination
                    count={Math.ceil(rows.length / rowsPerPage)}
                    page={page}
                    onChange={handleChangePage}
                    sx={{ mt: 2, mb: 4 }}
                    color="success"
                />
            </Box>
        </Paper>
    );
};
