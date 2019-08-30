# PushEx

[![Hex.pm](https://img.shields.io/hexpm/v/push_ex.svg)](https://hex.pm/packages/push_ex)
[![Hex.pm](https://img.shields.io/hexpm/dt/push_ex.svg)](https://hex.pm/packages/push_ex)
[![Hex.pm](https://img.shields.io/hexpm/l/push_ex.svg)](https://github.com/pushex-project/pushex/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/pushex-project/pushex.svg?branch=master)](https://travis-ci.org/pushex-project/pushex)

PushEx is an implementation of Phoenix websockets/channels which handles best practices of running websockets for you, but allows your business logic to be specified through simple behaviour modules.

PushEx is currently in release candidate of `1.0.1`. The library is fully functional, but I am waiting until we are using this in production before releasing `1.0.1`. Production version of `1.0.0` is skipped due to glitch in hex.pm with too many rc versions (I'm liberal about cutting new pre-releases to test new features as needed).

## Key Links

- [Hexdocs.pm](https://hexdocs.pm/push_ex)
- [Pushex.js Github](https://github.com/pushex-project/pushex.js)
- [Pushex.js npm](https://www.npmjs.com/package/pushex.js)

## Features

- Push socket/channel implementation
- Push API implementation
- Customizable hook points to allow authentication and instrumentation
- Designed for performance with a large number of connections and messages
- JS client built on top of Phoenix.js

## Compared to Phoenix

PushEx is built on top of Phoenix Channel and Presence. If you look at the source code, it is actually a very thin layer on top of this core functionality; most of the code is around ensuring a scalable system which is set up for success without knowing how Phoenix works.

PushEx is better compared to a pre-built microservice that is ready to go. By implementing a few application specific functions, you can bring a fully baked push WebSocket server to your application. You will also benefit from community upgrades regarding functionality and performance; this is true both for Phoenix changes and PushEx changes. You do *not* need to know how Phoenix works in order to build a scalable system.

## Get Started

The best way to get started is by following the [Standalone Installation Guide](https://hexdocs.pm/push_ex/standalone.html).

It is possible to integrate PushEx with an existing Phoenix application, although this is not recommended for applications which are deployed often. The installation guide for this case is slated for the future. Please open an issue if you'd like it for your use case.

The [PushEx docs](https://hexdocs.pm/push_ex) contain many guides such as authentication, deployment, instrumentation, PushEx.js, PubSub, API usage. Please see this guide for up to date information. You can also access these guides in the repo folder `guides`.

## Current Version

Add the following to your mix.exs `deps` in order to get the latest version of PushEx:

```
  {:push_ex, "~> 1.0.0-rc6"},
```

## Examples

Examples are located in the examples directory. The test_frontend_socket example is the most complete and simple example.

## Company Sponsor

A big thanks to [SalesLoft](https://salesloft.com) for helping with the development and open-sourcing of PushEx. Their support of my professional and personal time into this project (it was formed in an Innovation Week) is the type of thing that makes them [Atlanta's best place to work](https://www.ajc.com/business/growing-software-firm-built-core-values/Xjnm3EnCNe4Cub0JNbPOZL/).
