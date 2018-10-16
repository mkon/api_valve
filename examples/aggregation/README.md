# Aggregation example

Simply run

```
rackup -p 8080
```

Inspecting the `config.ru` you can see can run any ruby code inside a routing block. Here we utilize
this to aggregate multiple API calls into a single response, parallelized.

As you can see from the `config.ru`, it will forward all requests according to this table:

| Method | Route         | Target                                                       |
|--------|---------------|--------------------------------------------------------------|
| GET    | /aggregated   | https://jsonplaceholder.typicode.com/posts/(1..5) Aggregated |
| GET    | *             | https://jsonplaceholder.typicode.com/*                       |
