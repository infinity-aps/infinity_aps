import Chart from 'chart.js';
import React, {Component} from 'react';
import ReactDOM from 'react-dom';
import socket from './socket';
import GlucoseChart from './charts/glucose_chart';

export default class ReactApp extends Component {
  componentWillMount() {
    let channel = socket.channel("loop_status:glucose", {});
    channel.join()
           .receive("ok", resp => { console.log("Joined successfully", resp); })
           .receive("error", resp => { console.log("Unable to join", resp); });

    channel.on("sgvs", msg => {
      console.log("Got message", msg);
      this.refs.glucoseChart.updateGlucoseData(msg.data);
    });
  }

  render() {
    return (
      <GlucoseChart ref="glucoseChart"/>
    )
  }
}

ReactDOM.render(
  <ReactApp/>,
  document.getElementById('glucose-react')
);
