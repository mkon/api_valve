# Basic example

Simply run

```
rackup -q -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Route          | Target                        |
|----------------|-------------------------------|
| /oauth/        | http://auth.host/oauth/       |
| /oauth/token   | http://auth.host/oauth/token  |
| /api/          | http://api.host/api/          |
| /api/something | http://api.host/api/something |
