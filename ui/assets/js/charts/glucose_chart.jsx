import React, {Component} from 'react';

export default class GlucoseChart extends Component {
  render() {
    return (
      <canvas id="glucoseChart" width="1000" height="500"></canvas>
    )
  }

  componentDidMount() {
    var ctx = document.getElementById("glucoseChart").getContext('2d');
    this.setState({ glucoseChart: this.initializeGlucoseChart(ctx) });
  }

  updateGlucoseData(sgvs) {
    let chartValues = sgvs.map((sgv) => {
      return {y: sgv.sgv, x: sgv.dateString};
    });
    console.log("Updating sgvs", this.state.glucoseChart.data.datasets[1]);
    this.state.glucoseChart.data.datasets[1].data = chartValues;
    this.state.glucoseChart.update();
  }

  initializeGlucoseChart(ctx) {
    Chart.defaults.global.elements.point.radius = 2;
    return new Chart(ctx, {
      type: 'line',
      responsive: true,
      data: {
        datasets: [{
          steppedLine: 'after',
          label: "Basal Rate",
          yAxisID: 'basal',
          fill: true,
          data: [
            {y: 0.8, x: "2018-02-18T13:04:00Z",},
            {y: 1.3, x: "2018-02-18T12:57:00Z",},
            {y: 3.0, x: "2018-02-18T12:53:00Z",},
            {y: 5.0, x: "2018-02-18T12:46:00Z",},
            {y: 4.0, x: "2018-02-18T12:42:00Z",},
            {y: 3.5, x: "2018-02-18T12:39:00Z",},
            {y: 3.2, x: "2018-02-18T12:30:00Z",},
            {y: 1.0, x: "2018-02-18T12:29:00Z",},
            {y: 0, x: "2018-02-18T12:21:00Z",},
            {y: 0.5, x: "2018-02-18T12:19:00Z"}
          ]
        },{
          label: "Sensor Glucose Values",
          yAxisID: 'glucose',
          fill: false,
          showLine: false,
          borderColor: "#3cba9f",
          backgroundColor: "#3cba9f"
        }],
      },
      options: {
        scales: {
          xAxes: [{
            type: 'time',
            display: true,
            gridLines: { display: false }
          }],
          yAxes: [{
            id: 'glucose',
            type: 'logarithmic',
            display: true,
            gridLines: { borderDash: [5, 15] },
            ticks: {
              min: 30,
              max: 450,
              callback: function(value, index, values) {
                return Number(value.toString());
              }
            },
            afterBuildTicks: function(pckBarChart) {
              pckBarChart.ticks = [];
              pckBarChart.ticks.push(40);
              pckBarChart.ticks.push(55);
              pckBarChart.ticks.push(70);
              pckBarChart.ticks.push(120);
              pckBarChart.ticks.push(145);
              pckBarChart.ticks.push(180);
              pckBarChart.ticks.push(400);
            }
          },{
            id: 'basal',
            display: true,
            gridLines: { drawOnChartArea: false },
            label: 'Basal Units',
            position: 'right',
            ticks: {
              min: 0,
              max: 40,
            },
            afterBuildTicks: function(pckBarChart) {
              pckBarChart.ticks = [];
              pckBarChart.ticks.push(0);
              pckBarChart.ticks.push(1);
              pckBarChart.ticks.push(2);
              pckBarChart.ticks.push(3);
              pckBarChart.ticks.push(4);
              pckBarChart.ticks.push(5);
            }
          }]
        }
      }
    });
  }
}
