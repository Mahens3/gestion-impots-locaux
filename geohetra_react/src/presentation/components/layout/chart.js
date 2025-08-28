
import CanvasJSReact from '@canvasjs/react-charts';


export const BarChart = ({ data, title }) => {

    var CanvasJSChart = CanvasJSReact.CanvasJSChart
    const options = {
        animationEnabled: true,
        axisY: {
            gridColor: '#EEEEEE',
            labelFormatter: function (e) {
                return new Intl.NumberFormat(undefined, { useGrouping: true }).format(e.value);
            },
        },
        axisX: {
            interval: 1,
            intervalType: null,
        },
        creditText: 'Dera',
        data: [
            {
                type: "column",
                name: title[0],
                showInLegend: "true",
                color: "#429F5F",
                toolTipContent: '{label}: {y}',
                dataPoints: data.map((item, index) => ({
                    "label": item.fkt,
                    "y": item.y
                }))
            },
            {
                type: "column",
                name: title[1],
                color: "#5C9BA5",
                showInLegend: "true",
                toolTipContent: '{label}: {y}',
                dataPoints: data.map((item, index) => ({ "label": item.fkt, "y": item.z }))
            }
        ]
    }

    return (<CanvasJSChart options={options} />)
}


export const SplineChart = ({ data }) => {

    var CanvasJSChart = CanvasJSReact.CanvasJSChart

    const options = {
        animationEnabled: true,
        axisY: {
            gridColor: '#EEEEEE',
            labelFormatter: function (e) {
                return new Intl.NumberFormat(undefined, { useGrouping: true }).format(e.value);
            },
        },
        axisX: {
            interval: 1,
            intervalType: null,
        },
        creditText: 'Dera',
        data: [
            {
                type: "spline",
                color: "#429F5F",
                toolTipContent: '{label}: {y}',
                dataPoints: data.map((item, index) => ({
                    "label": item.month,
                    "y": item.amount
                }))
            },
        ]
    }

    return (<CanvasJSChart options={options} />)
}



