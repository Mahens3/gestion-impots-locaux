let baseUrl
if (process.env.NODE_ENV === 'production') {
    // API pour le mode production
    baseUrl = process.env.REACT_APP_BASENAME_PROD
} else {
    // API pour le mode developpement
    baseUrl = process.env.REACT_APP_BASENAME_DEV
}

export default baseUrl