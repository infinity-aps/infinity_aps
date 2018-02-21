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
    let glucoseDataset = this.state.glucoseChart.data.datasets.find((dataset) => {
      if(dataset.yAxisID === 'glucose') { return true; }
      return false;
    });
    glucoseDataset.data = chartValues;
    this.state.glucoseChart.update();
  }

  initializeGlucoseChart(ctx) {
    Chart.defaults.global.elements.point.radius = 2;
    return new Chart(ctx, {
      type: 'line',
      responsive: true,
      data: {
        datasets: [{
          label: "Sensor Glucose Value",
          yAxisID: 'glucose',
          fill: true,
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
          }]
        }
      }
    });
  }
}
