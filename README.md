# ApiValve

[![Gem Version](https://badge.fury.io/rb/api_valve.svg)](https://badge.fury.io/rb/api_valve)
![](https://github.com/mkon/api_valve/workflows/Test/badge.svg?branch=main)
[![Depfu](https://badges.depfu.com/badges/1f5892cc85d02997050e0a4d077c7dc4/overview.svg)](https://depfu.com/github/mkon/api_valve?project_id=5958)

Extensible rack application that serves as lightweight API reverse proxy.

## Installation

Just add the gem to your `Gemfile`

```ruby
gem 'api_valve'
```

## Usage

See the [examples](https://github.com/mkon/api_valve/tree/master/examples) section on how to
create & configure your own proxy using this gem.

### Headers

By default the following headers are forwarded:

* `Accept`
* `Content-Type`
* `User-Agent`
* `X-Real-IP`
* `X-Request-Id`

Additionally these headers are generated:

* `X-Forwarded-For`: The ApiGateway is added to the list
* `X-Forwarded-Host`: Filled with original request host
* `X-Forwarded-Port`: Filled with original request port
* `X-Forwarded-Prefix`: Filled with the path prefix of the forwarder within the Api Gateway (eg `SCRIPT_NAME` env)
* `X-Forwarded-Proto`: Filled with original request scheme
