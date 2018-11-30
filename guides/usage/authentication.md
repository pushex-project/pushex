# Authentication

Ensuring that your PushEx installation is properly authenticated is crucial for security. Without proper authentication controls, an unintended party could connect to your system or send out pushes through your API.

## Controllers

`PushEx.Behaviour.Controller.auth/2` is the function that will be invoked to authenticate your API controller. The module that implements the Controller Behaviour will be set using Application config:

```elixir
config :push_ex, PushExWeb.PushController, controller_impl: DemoApp.Controller
```

The simplest way to authenticate your controller is to return either `:ok` or `:error` atoms from your `auth/2` implementation. Your implementation should *always* have a case that must be met for `:ok` to be returned, or your system will not be secure.

It is recommended to never expose the authentication for your controller directly to your users, unless you add additional validation of the parameters for that user. Without full validation of the parameters, it would be possible for a user to send pushes for a channel that they don't have permission to access.

## Socket / Channel

The socket and channel authentication are a bit more complex than the controller authentication. This is because the controller authentication will commonly be system -> system while the socket authentication is inherently user based.

`PushEx.Behaviour.Socket` includes `socket_connect/3` and `channel_join/3` callbacks in order to provide authentication for sockets and channels.

### Socket vs Channel

A user may be generally allowed to open a socket to the system (they aren't listening to messages, but have the ability to start) but may be denied from joining certain channels. An example of this is that "user 1" is logged in (has ability to open a socket) but cannot join "user 2"'s push channel. Two different authentication strategies must be provided based on this.

You can set your socket authentication implementation by using:

```elixir
config :push_ex, PushExWeb.PushSocket, socket_impl: DemoApp.Socket
```

### Socket

Socket authentication answers the question "should this request be able to connect to websockets at all?". Due to limitations in Phoenix Websocket implementation, it is not possible to use cookies when implementing socket authentication. Thus, it is very common to include a server signed token when connecting to a socket.

In PushEx.js, this would be done by implementing `getParams` with a returned `token` parameter. I recommend JWT as the token parameter as it provides tamper-proof secrets that can be passed through the client without worry. It is important to not put secrets in the JWT, however, because JWT tokens can be inspected by anyone regardless of whether they have the key or not!

Your socket authentication will return either `{:ok, socket}` or `:error` based on the result of your authentication check. It is possible to include values in the socket using `Phoenix.Socket.assign/3`. In my systems, I will commonly take the contents of the JWT tokens (which include user ID) and `assign` that into a variable such as `user_id`. You will see why this is useful in the channel authentication.

### Channel

Channel authentication answers the question "should this connected socket be able to connect to this specific topic?". An example of this is a socket opened by "user 1" joining the channel `private-user-1`. You might answer this question "yes" because the user's ID and the channel user ID match. However, you may answer "no" to whether "user 1" can join `private-user-10` because the IDs do not match.

The first argument of `channel_join` is the string containing the channel topic that is being joined. This topic is what you push to, and will often contain a piece of identifying information such as user ID. There are exceptions to this rule, however, such as an app-wide channel that all users can connect to.

Your channel authentication should return either `{:ok, socket}` or `:error` based on the result of your authentication check. In my systems, I will commonly take the assigned socket content such as `user_id` and verify that the channel topic string matches this value. In doing this, I must ensure that the socket contains all information that would be needed to identify all topics that I might connect to.

## General Recommendations

I have found that JSON Web Tokens (JWTs) are the easiest way to pass information from the frontend to the backend for authentication purposes and I highly recommend looking at them as part of your authentication strategy. If you go down this route, consider what would happen if your PushEx server rebooted (like during a deploy): if all of your connected users had to refetch a token from your server, would that amount of load be acceptable? My answer to this question is to fetch a short lived JWT every 10 minutes, just in case it's needed.

Write ExUnit tests for all of your authentication functions. Even if you write no other tests, it is very important to have your security code covered by tests.

Do not write authentication functions that return "ok" results without verifying that they are indeed okay. This would open your system for exploitation. This is equivalent to writing a login function that always returns true.
