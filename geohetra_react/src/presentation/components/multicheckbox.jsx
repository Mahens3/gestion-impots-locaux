import { useState } from "react"

const CheckBox = (props) => {
    const [checked, setChecked] = useState(false)
    const handleChange = (e) => {
        setChecked(props.handleChange(e.target.value))
    }
    return (
        <div key={props.index}>
            <input key={"checkbox" + props.index} checked={checked} onChange={handleChange} type="checkbox" value={props.value} /> {props.value}
        </div>
    )
}

const MultiCheckbox = (props) => {
    const check = (str_to_search) => {
        var regex = new RegExp(str_to_search)
        var isExisted = regex.test(props.val)
        if (isExisted) {
            props.changeValue(props.val.replace(str_to_search + ", ", ""))
        }
        else {
            props.changeValue(props.val + str_to_search + ", ")
        }

        return !isExisted
    }

    var checkbox = []
    props.checkbox.map((value, key) => {
        checkbox.push(
            <CheckBox key={key} index={key} handleChange={check} value={value} />
        )
    })

    return (
        <div>
            {checkbox}
        </div>
    )
}

export default MultiCheckbox