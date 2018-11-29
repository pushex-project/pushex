# Usage - Push API

PushEx exposes a very small interface to create pushes that are sent to connected clients. This interface is exposed automatically for you, and is protected through the `PushEx.Behaviour.Controller` implementation that is defined for your application.

## Security

Do not ship an implementation of controller behaviour to production that does not have authentication or protection. This would put your system at risk of sending arbitrary data to your connected clients.

## API Request

The route `POST /api/push` is exposed on your web server. For instance, the URL in examples/test_frontend_socket is `http://localhost:4004/api/push`.

The push controller accepts the following arguments:

* `channel` - An array or single string containing the channels that the push will be delivered to.
* `data` - The JSON compatible data that will be sent in the push.
* `event` - The name of the event that will be pushed.

The controller will respond with a JSON response status 200 if successful, containing a sanitized version of the data delivered in the push. This allows you to debug if the push is not coming through correctly.

In the case of an error, such as missing fields, the server will return a JSON response 422 with an error message.

In the case of an invalid authentication, the server will return a JSON response 403 "Access Forbidden".

## Example

Using the examples/test_frontend_socket application, the following JSON request/response is seen:

```
curl -i -X POST \
    http://localhost:4004/api/push \
    -H 'content-type: application/json' \
    -d '{
    "channel": ["test", "test2", "test"],
    "data": "data",
    "event": "woohoo"
  }'

HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 59
content-type: application/json; charset=utf-8
date: Thu, 29 Nov 2018 05:26:04 GMT
server: Cowboy
x-request-id: 2llo21pptuh5gla7cg0002v4

{"channel":["test","test2"],"data":"data","event":"woohoo"}
```

Notice that the channel was passed with test duplicated, but was returned with a single test channel. This is an example of how the response will be the real data that the server processed, and not a plain mirror of the input.
