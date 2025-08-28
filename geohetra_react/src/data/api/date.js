export const getDate = () => {
    var date = new Date()
    var d = date.getFullYear().toString() + (date.getMonth() + 1 ).toString() + date.getDate().toString() + date.getHours().toString() + date.getMinutes().toString() + date.getSeconds().toString() ;
    d+=localStorage.getItem("phone")
    return d
}