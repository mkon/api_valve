# Basic example

Simply run

```
rackup -q -p 8080
```

As you can see from the `config.ru`, it will forward all requests according to this table:

| Route          | Target                                         |
|----------------|------------------------------------------------|
| /api/*         | http://jsonplaceholder.typicode.com/*          |
