
## For Development

```sh
$ rake db:create_migration  # create an ActiveRecord migration in ./db/migrate
$ rake db:migrate           # migrate database
```

**Start App Controller**

```sh
$ sudo ruby app.rb
```

or

```sh
$ sudo rackup -p 1234
```

## Key

### Key Create

```sh
$ curl -n -X POST http://xxx/keys \
-H "Content-Type: application/json" \
-d '{
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
}'
```

**Response**

```sh
{
  "id": "b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
  "fingerprint": "b3:70:a2:0f:d8:50:64:8d:8f:db:f3:3d:a7:79:00:92",
}
```

### Key Delete

```sh
$ curl -n -X DELETE http://xxx/keys/b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69
```

**Response**

```sh
{
  "id": "b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
  "fingerprint": "b3:70:a2:0f:d8:50:64:8d:8f:db:f3:3d:a7:79:00:92",
}
```

### Key Info

```sh
$ curl -n -X GET http://xxx/keys/b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69
```

**Response**

```sh
{
  "id": "b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69",
  "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
  "fingerprint": "b3:70:a2:0f:d8:50:64:8d:8f:db:f3:3d:a7:79:00:92",
}
```

### Key List

```sh
$ curl -n -X GET http://xxx/keys
```

**Response**

```sh
[
  {
    "id": "b1fff0be-ee7c-4e6a-8e6b-c55f01d75a69",
    "public_key": "ssh-rsa AAAAB3NzaC1ycVc/../839Uv username@example.com"
    "fingerprint": "b3:70:a2:0f:d8:50:64:8d:8f:db:f3:3d:a7:79:00:92",
  }
]
```

## App

### APP Create

```sh
$ curl -n -X POST http://xxx/apps \
-H "Content-Type: application/json" \
-d '{
  "name": "test"
}'
```

**Response**

```sh
{
  "name": "test"
}
```

### App Delete

```sh
$ curl -n -X DELETE http://xxx/apps/test
```

**Response**

```sh
{
  "name": "test"
}
```

### App Info

```sh
$ curl -n -X GET http://xxx/apps/test
```

**Response**

```sh
{
  "id": "5e7c67899db1",
  "ip": "172.17.2.241",
  "port": "5000",
  "url": "http://xxx.yyy"
}
```

### App List

```sh
$ curl -n -X GET http://xxx/apps
```

**Response**

```sh
[
  {
    "name": "test"
  },
  {
    "name": "platform"
  }
]
```

## App Operation

### App Deploy

```sh
$ curl -n -X POST http://xxx/apps/$APP_NAME/deploy \
-H "Content-Type: application/json" \
```

## Config

### Config Create

```sh
$ curl -n -X POST http://xxx/apps/$APP_NAME/config \
-H "Content-Type: application/json" \
-d '{
  "name": "test",
  "port": "5000"
}'
```

**Response**

```sh
{
  "name": "test",
  "port": "5000"
}
```

### Config Delete

```sh
$ curl -n -X DELETE http://xxx/apps/$APP_NAME/config/name
```

**Response**

```sh
{
  "name": "test"
}
```

### Config List

```sh
$ curl -n -X GET http://xxx/apps/$APP_NAME/config
```

**Response**

```sh
{
  "KEY1": "VALUE1",
  "KEY2": "VALUE2",
  ...
}
```

## Domain

### Domain List

```sh
$ curl -n -X GET http://xxx/apps/$APP_NAME/domains
```

**Response**

```sh
[
  {
    "domain": "im.team.work"
  }
]
```

## Log

```sh
$ curl -n -X GET http://xxx/apps/$APP_NAME/logs
```

or

```sh
$ curl -n -X GET http://xxx/apps/$APP_NAME/logs?lines=1000
```

**Response**

```sh
127.0.0.1 - - [23/Jan/2015:09:13:04 +0000] "GET / HTTP/1.1" -1 - 19.1057
127.0.0.1 - - [23/Jan/2015:09:14:25 +0000] "GET / HTTP/1.1" -1 - 60.0006
```
