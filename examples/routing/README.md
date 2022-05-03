# Routing example

Simply run

```
rackup -q -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Method | Route                 | Target                |
|--------|-----------------------|-----------------------|
| GET    | /api/*                | http://api.host/api/* |
| GET    | /api/prefix/*         | http://api.host/api/* |
| POST   | *                     | HTTP Error 403        |
| PUT    | *                     | HTTP Error 403        |
| PATCH  | *                     | HTTP Error 403        |
