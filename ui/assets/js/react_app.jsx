import Chart from 'chart.js';
import React from 'react';
import ReactDOM from 'react-dom';
import GlucoseChart from './charts/glucose_chart';

ReactDOM.render(
  <GlucoseChart/>,
  document.getElementById('glucose-react')
)
