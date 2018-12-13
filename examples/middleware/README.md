# Middleware example

Simply run

```
rackup -p 8080
```

Inspecting the `config.ru` you can see that it is possible to add Middleware to a proxy just like to any other rack application.

This can be used to add custom middleware only to certain proxys in a multi proxy/cascade setup.
