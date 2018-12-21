# Permissions example

Simply run

```
rackup -p 8080
```

As you can see from the `config.ru`, it will deny all requests which do not contain a specific api token in the header.
