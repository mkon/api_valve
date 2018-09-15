# Cascade example

By using cascade, you can run multiple proxies in one directory. It has a very similar
behavior to `Rack::Cascade`, however it only tries the next proxy if the request is not
routed, instead on any 404 response like `Rack::Cascade` (which could mean the request
was already proxied, but the target host returned 404).

Simply run

```
rackup -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Method | Route                 | Target                        |
|--------|-----------------------|-------------------------------|
| ANY    | /api/beer/*           | http://drinks.host/api/beer*  |
| ANY    | /api/snacks/*         | http://foods.host/api/snacks* |
| ANY    | *                     | HTTP Error 404                |
