import React, {Component} from 'react';

export default class GlucoseChart extends Component {
  render() {
    return (
      <canvas id="glucoseChart" width="1500" height="800"></canvas>
    )
  }

  componentDidMount() {
    var ctx = document.getElementById("glucoseChart").getContext('2d');

    var glucoseChart = new Chart(ctx, {
      type: 'line',
      responsive: true,
      data: {
        datasets: [{
          steppedLine: 'after',
          label: "Basal Rate",
          yAxisID: 'basal',
          fill: true,
          data: [{
            y: 0.8,
            x: "2018-02-12T13:04:00Z",
          }, {
            y: 1.3,
            x: "2018-02-12T12:57:00Z",
          }, {
            y: 3.0,
            x: "2018-02-12T12:53:00Z",
          }, {
            y: 5.0,
            x: "2018-02-12T12:46:00Z",
          }, {
            y: 4.0,
            x: "2018-02-12T12:42:00Z",
          }, {
            y: 3.5,
            x: "2018-02-12T12:39:00Z",
          }, {
            y: 3.2,
            x: "2018-02-12T12:30:00Z",
          }, {
            y: 1.0,
            x: "2018-02-12T12:29:00Z",
          }, {
            y: 0,
            x: "2018-02-12T12:21:00Z",
          }, {
            y: 0.5,
            x: "2018-02-12T12:19:00Z"
          }]
        },{
          label: "Sensor Glucose Values",
          yAxisID: 'glucose',
          fill: false,
          borderColor: "#3cba9f",
          data: [{
            y: 250,
            x: "2018-02-12T13:04:00Z",
          }, {
            y: 158,
            x: "2018-02-12T12:59:00Z",
          }, {
            y: 108,
            x: "2018-02-12T12:54:00Z",
          }, {
            y: 136,
            x: "2018-02-12T12:49:00Z",
          }, {
            y: 130,
            x: "2018-02-12T12:44:00Z",
          }, {
            y: 120,
            x: "2018-02-12T12:39:00Z",
          }, {
            y: 112,
            x: "2018-02-12T12:34:00Z",
          }, {
            y: 104,
            x: "2018-02-12T12:29:00Z",
          }, {
            y: 150,
            x: "2018-02-12T12:24:00Z",
          }, {
            y: 96,
            x: "2018-02-12T12:19:00Z"
          }]
        }],
      },
      options: {
        scales: {
          xAxes: [{
            type: 'time',
            display: true
          }],
          yAxes: [{
            id: 'glucose',
            type: 'logarithmic',
            display: true,
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
            label: 'Basal Units',
            position: 'right',
            ticks: {
              min: 0,
              max: 13,
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
