
const socket = new Phoenix.Socket("ws://localhost:4004/push_socket", {params: {}})
const pushex = new Pushex.Pushex('ws://localhost:4004/push_socket', {})

function joinChannel(name) {
  const channel = socket.channel(name, {})
  channel.on("msg", msg => console.log("Got message", name, msg) )

  channel.join()
    .receive("ok", () => console.log("Joined", name) )
    .receive("error", ({ reason }) => console.log("failed join", name, reason) )
    .receive("timeout", () => console.log("Networking issue. Still waiting...", name) )
}


function notifyMe() {
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
      alert("This browser does not support desktop notification");
    }
  
    // Let's check whether notification permissions have already been granted
    else if (Notification.permission === "granted") {
      // If it's okay let's create a notification
      var notification = new Notification("Hi there!");
    }
  
    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== "denied") {
      Notification.requestPermission().then(function (permission) {
        // If the user accepts, let's create a notification
        if (permission === "granted") {
          var notification = new Notification("Hi there!");
        }
      });
    }
  
    // At last, if the user has denied notifications, and you 
    // want to be respectful there is no need to bother them any more.
  }
Notification.requestPermission().then(function(result) {
    console.log(result);
})
function spawnNotification(body, icon, title) {
    var options = {
        body: body,
        icon: icon
    };
    var n = new Notification(title, options);
}
socket.connect()

joinChannel("test")
joinChannel("test2")

pushex.subscribe('test').bind('*', (event, data) => {
  spawnNotification('body', 'icon', 'title')
  console.log('test channel received event/data', event, data)
})
pushex.subscribe('test2').bind('*', (event, data) => {
  spawnNotification('body', 'icon', 'title')
  console.log('test2 channel received event/data', event, data)
})

pushex.connect()
