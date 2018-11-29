# PushEx

[![Hex.pm](https://img.shields.io/hexpm/v/push_ex.svg)](https://hex.pm/packages/push_ex)
[![Hex.pm](https://img.shields.io/hexpm/dt/push_ex.svg)](https://hex.pm/packages/push_ex)
[![Hex.pm](https://img.shields.io/hexpm/l/push_ex.svg)](https://github.com/pushex-project/pushex/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/pushex-project/pushex.svg?branch=master)](https://travis-ci.org/pushex-project/pushex)

PushEx is an implementation of Phoenix websockets/channels which handles best practices of running websockets for you, but allows your business logic to be specified through simple behaviour modules.

PushEx is currently in a pre-release stage as requirements of full release are being met (tests, documentation, load testing).

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

## Get Started

The best way to get started is by following the [Standalone Installation Guide](https://hexdocs.pm/push_ex/standalone.html).

It is possible to integrate PushEx with an existing Phoenix application, although this is not recommended for appplications which are deployed often. The installation guide for this case is slated for the future. Please open an issue if you'd like it for your use case.

## Current Version

Add the following to your mix.exs `deps` in order to get the latest version of PushEx:

```
  {:push_ex, "~> 1.0.0-rc2"},
```

## Examples

Examples are located in the examples directory. The test_frontend_socket example is the most complete and simple example.

## Company Sponsor

A big thanks to [SalesLoft](https://salesloft.com) for helping with the development and open-sourcing of PushEx. Their support of my professional and personal time into this project (it was formed in an Innovation Week) is the type of thing that makes them [Atlanta's best place to work](https://www.ajc.com/business/growing-software-firm-built-core-values/Xjnm3EnCNe4Cub0JNbPOZL/).
