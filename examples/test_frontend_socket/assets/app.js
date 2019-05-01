// Main demonstration of pushex in normal operation
const pushex = new Pushex.Pushex('ws://localhost:4004/push_socket', {})

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

// Demonstrate unsubscribe from a Channel
// It stays open but won't receive any messages because the topic is not subscribed to
// It will disconnect after 5s due to the timeout below
const pushexTestLeaving = new Pushex.Pushex('ws://localhost:4004/push_socket', {})
pushexTestLeaving.connect()
pushexTestLeaving.subscribe('willDisconnect').bind('*', (event, data) => {
  console.error('Should not have received anything from willDisconnect')
})
pushexTestLeaving.unsubscribe('willDisconnect')

setTimeout(() => {
  pushexTestLeaving.disconnect()
}, 5000)
