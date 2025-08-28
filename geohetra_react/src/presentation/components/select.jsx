import React from 'react'
import { useEffect } from 'react';
import { useState } from "react";

export const Select = (props) => {
    const [options, setOptions] = useState([])
    const [value, setValue] = useState(props.options[0])
    const [other, setOther] = useState("")

    const handleChange = (e) => {
        setValue(e.target.value)
        setOther("")
        props.handleChange(e)
    }  

    const handleOther = (e) => {
        setOther(e.target.value)
        props.handleChange(e)
    }

    useEffect(()=> {
        if(options.length==0){
            var newOptions = []
            props.options.map((value, index) => {
                newOptions.push(<option key={index} value={value}>{value}</option>)
            })
            newOptions.push(<option key={newOptions.length} value="Autre">Autre</option>)
            setOptions(newOptions)
        }
        else{
            if(props.options.indexOf(props.value)>=0){
                setValue(props.value)
            }
            else {
                setValue("Autre")
                setOther(props.value)
            }
        }
    }, [options])

    return (
        <>
            <select value={value} onChange={handleChange} name="" id="" className='form-control'>
                {options}
            </select>
            { value=="Autre" ? <input type="text" style={{ marginTop : 4 }} onChange={handleOther} className='form-control' value={other} placeholder="Autre à preciser" /> : null }
        </>
    )
}

export const Select2 = ({data, val, name, index, onChange}) => {
    const [options, setOptions] = useState([])
    const [value, setValue] = useState()
    const handleChange = (e) => {
        setValue(e.target.value)
        onChange(e)
    }  

    useEffect(()=> {
        console.log(value)
    }, [value])

    useEffect(()=> {
        if(options.length==0){
            var newOptions = []
            data.map((value, id) => {
                newOptions.push(<option key={id} value={value[index]}>{value[name]}</option>)
            })
            setValue(val)
            setOptions(newOptions)
        }
    }, [options])

    return (
            <select value={value} onChange={handleChange} name="" id="" className='form-control'>
                {options}
            </select>
    )
}