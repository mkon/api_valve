# Routing example

Simply run

```
rackup -q -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Method | Route             | Target                                      |
|--------|-------------------|---------------------------------------------|
| GET    | /api/*            | http://jsonplaceholder.typicode.com/*       |
| GET    | /api/customers/*  | http://jsonplaceholder.typicode.com/users/* |
| POST   | *                 | HTTP Error 403                              |
| PUT    | *                 | HTTP Error 403                              |
| PATCH  | *                 | HTTP Error 403                              |
