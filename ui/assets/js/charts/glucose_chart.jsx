import React, {Component} from 'react';
import moment from 'moment';

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

  mostRecentGlucose() {
    let glucoseData = this.glucoseDataset().data;
    return glucoseData[glucoseData.length - 1];
  }

  glucoseDataset() {
    return this.state.glucoseChart.data.datasets.find((dataset) => {
      if(dataset.label === "Sensor Glucose Value") { return true; }
      return false;
    });
  }

  predictedDataset() {
    return this.state.glucoseChart.data.datasets.find((dataset) => {
      if(dataset.label === "Predicted Glucose Value") { return true; }
      return false;
    });
  }

  updateGlucoseData(sgvs) {
    let chartValues = sgvs.map((sgv) => {
      return {y: sgv.sgv, x: sgv.dateString};
    });
    this.glucoseDataset().data = chartValues;
    this.predictedDataset().data = this.filterPredictedGlucose(this.predictedDataset().data);
    this.state.glucoseChart.update();
  }

  updatePredictedGlucoseData(predicted) {
    if(!predicted) { return; }
    let chartValues = predicted.map((bg) => {
      return {y: bg.bg, x: bg.dateString};
    });
    let filteredGlucose = this.filterPredictedGlucose(chartValues);
    this.predictedDataset().data = filteredGlucose;
    this.state.glucoseChart.update();
  }

  filterPredictedGlucose(predicted) {
    let mostRecentGlucose = this.mostRecentGlucose();
    if(!mostRecentGlucose) { return []; }
    return predicted.filter((bg) => {
      if(!mostRecentGlucose || moment(bg.x).isAfter(mostRecentGlucose)) {
        return true;
      }
      return false;
    });
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
          showLine: false,
          borderColor: "#3cba9f",
          backgroundColor: "#3cba9f"
        },{
          label: "Predicted Glucose Value",
          yAxisID: 'predictedGlucose',
          showLine: false,
          borderColor: "purple",
        }],
      },
      options: {
        hover: {
          mode: 'nearest'
        },
        animation: false,
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
            id: 'predictedGlucose',
            type: 'logarithmic',
            display: false,
            ticks: {min: 30, max: 450}
          }]
        }
      }
    });
  }
}
