# Basic example

Simply run

```
rackup -p 8080
```

As you can see from the `config.ru`, it will forward all requests from _/oauth/_ to _http://auth.host/oauth/_,
and all requests from _/api/_ to _http://api.host/api/_.
