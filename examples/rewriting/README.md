# Rewriting example

Simply run

```
rackup -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Method | Route                          | Target                                                   |
|--------|--------------------------------|----------------------------------------------------------|
| GET    | /api/accounts/:id/transactions | http://api.host/api/transactions (header Account-Id set) |
