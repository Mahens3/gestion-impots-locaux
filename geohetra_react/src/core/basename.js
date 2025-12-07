let baseUrl;
if (process.env.NODE_ENV === 'production') {
  baseUrl = process.env.REACT_APP_BASENAME_PROD || "/";
} else {
  baseUrl = process.env.REACT_APP_BASENAME_DEV || "/";
}

export default baseUrl;