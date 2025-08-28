import React,{ useState } from "react"
import { useEffect } from "react"

const CheckBoxOption = ({data, name, onChange}) => {
    const [checked, setChecked] = useState(null)

    const handleChange = () => {
        onChange(name)
        setChecked(!checked)
    }

    const verify = () => {
        if(data.indexOf(name)<0){
            setChecked(false)
        }
        else{
            console.log("checked : " + name)
            setChecked(true)
        }
    }
    useEffect(()=> {
        if(checked==null){
           verify() 
        }
    }, [checked])

    
    return (
        <input type="checkbox" checked={checked} onClick={handleChange}/>
    )
}

export default CheckBoxOption