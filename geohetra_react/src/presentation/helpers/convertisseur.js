const convert = (nbr) => {
    const unite = ["","un", "deux", "trois", "quatre", "cinq", "six", "sept", "huit", "neuf"]
    const dizaine = {"10" : "dix", "11" : "onze", "12" : "douze", "13" : "treize", "14" : "quatorze", "15" : "quinze", "16" : "seize", "17" : "dix sept", "18" : "dix huit", "19" : "dix neuf"}
    const param1 = ["", " mille"," million"," milliard"]
    const param2 = {"20" : "vingt", "30" : "trente", "40" : "quarante", "50" : "cinquante", "60" : "soixante", "80" : "quatre-vingt"}
    const str = nbr + ""

    const fraction = (data) => {
        let reste = data.length % 3
        let add = 0;
        if(reste>0){
            add = 3 - reste
        }

        for(var i=0; i<add; i++){
            data = "0" +  data
        }
        return toList(data)
    }

    const toList = (data) => {
        let array = []
        for(var i=0; i<data.length; i+=3){
            array.push(data.substr(i,i+3))
        }
        return toString(array)
    }

    const toString = (data) =>{
        let letterNbr = ""
        let count = 0
        for(var i=data.length - 1; i>-1; i--){
            letterNbr = tri(data[i]) + param1[count] + " " + letterNbr 
            count += 1
        }
        if((nbr+"").length==4 && str[0]=="1"){
            letterNbr = letterNbr.replace("un","")
        }
        return letterNbr.trim()
    }

    const tri = (data) => {
        let str = ""
        if(unite[parseInt(data[1] + data[2]) + ""]!=undefined){
            str = unite[parseInt(data[1] + data[2]) + ""]
        }
        else if(data[1]=="9"){
            if(data[2]=="0"){
                str = "quatre-vingt";
            }
            else{
                str = "quatre-vingt " + dizaine["1" + data[2]]
            }
        }
        else if(data[1]=="7"){
            if(data[2]=="0"){
                str = "soixante-dix";
            }
            else{
                str = "soixante " + dizaine["1" + data[2]]
            }
        }
        else if(dizaine[parseInt(data[1] + data[2]) + ""]!=undefined){
            str = dizaine[parseInt(data[1] + data[2]) + ""] 
        }
        else{
            let newdata = param2[data[1] + "0"] + " " + unite[data[2]] 
            str = newdata.trim()
        }

        return (getCentaine(data[0]) + " " + str).trim()
    }

    const getCentaine = (first) => {
        if(first == 0){
            return ""
        }
        else if(first=="1"){
            return "cent"
        }
        else{
            return unite[first] + " cent"
        }
    }

    return fraction(str)

}

export const formatter = (number) => {
    return number.toLocaleString();
}

export default convert