# PushEx

PushEx is an implementation of Phoenix websockets/channels which handles best practices of running websockets for you, but allows your business logic to be specified through simple behaviour modules.

PushEx is currently in a pre-release stage as requirements of full release are being met (tests, documentation, load testing).

## Features

- Push socket/channel implementation
- Push API implementation
- Customizable hook points to allow authentication and instrumentation
- Designed for performance with a large number of connections and messages

## Get Started

The best way to get started is by following the [Standalone Installation Guide](https://hexdocs.pm/push_ex/standalone.html).

## TODO (Prioritized)

- Method to get the size of the item buffer
- Test PushEx.js
- Write JS documentation
- Better controller 422 handling (show specific field reasons)
- Load testing harness
- Write installation guide (existing phoenix app)

## Possible Enhancements

- Replace `PushEx.Instrumentation.Push` implementation as phoenix instrumenters
  - This would be for performance reasons
  - It may not be necessary depending on the results of load testing
