export const getDate = () => {
    var date = new Date();
    // Obtenez les parties de la date
    var year = date.getFullYear();
    var month = (date.getMonth() + 1).toString().padStart(2, '0'); // Les mois sont indexés à partir de 0
    var day = date.getDate().toString().padStart(2, '0')
    // Formatage de la date et de l'heure
    return year + '-' + month + '-' + day
}

export const getTime = () => {
    var date = new Date();
    // Obtenez les parties de l'heure
    var hours = date.getHours().toString().padStart(2, '0');
    var minutes = date.getMinutes().toString().padStart(2, '0');
    var seconds = date.getSeconds().toString().padStart(2, '0');

    return hours + ':' + minutes;
}