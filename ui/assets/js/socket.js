import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {}}); // token: window.userToken}});
socket.connect();

let channel = socket.channel("logs", {});
channel.join()
       .receive("ok", resp => { console.log("Joined successfully to logs channel", resp); })
       .receive("error", resp => { console.log("Unable to join to logs channel", resp); });

channel.on("log:new", msg => {
  console.log("New log message:", msg);
  // Things to do when receiving a log message
});
export default socket;
