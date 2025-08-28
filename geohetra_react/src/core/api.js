let apiUrl
if (process.env.NODE_ENV === 'production') {
    // API pour le mode production
    apiUrl = process.env.REACT_APP_APACHE_URL
} else {
    // API pour le mode developpement
    apiUrl = process.env.REACT_APP_LARAVEL_URL
}

export default apiUrl