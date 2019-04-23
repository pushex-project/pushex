(() => {
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

  Notification.requestPermission().then(function(result) {
    console.log('Notification.requestPermission', result)
  })

  let stagedNotifications = []

  function stageNotification(body) {
    stagedNotifications.push(body)
    setTimeout(clearNotifications, 250)
  }

  function clearNotifications() {
    if (stagedNotifications.length > 0) {
      const body = stagedNotifications.join('\n')
      stagedNotifications = []
      spawnNotification(body)
    }
  }

  function spawnNotification(body) {
      var options = {
        body: body,
        icon: '/icon.png'
      }
      new Notification('Got data', options)
  }

  socket.connect()

  joinChannel("test")
  joinChannel("test2")
  joinChannel("my-public-channel")

  pushex.subscribe('test').bind('*', (event, data) => {
    stageNotification(`test: ${event}-${data}`)
    console.log('test channel received event/data', event, data)
  })
  pushex.subscribe('test2').bind('*', (event, data) => {
    stageNotification(`test2: ${event}: ${data}`)
    console.log('test2 channel received event/data', event, data)
  })
  pushex.subscribe('my-public-channel').bind('*', (event, data) => {
    stageNotification(`test2: ${event}: ${data}`)
    console.log('test2 channel received event/data', event, data)
  })

  pushex.connect()
})()
