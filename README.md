# TCP proxy

Simple TCP proxy written in OCaml and Core Unix library

## How to run

Install dependencies
```
esy install
```

Start new netcat server
```
nc -l -p 8080
```

Start the proxy / interceptor
```
esy x tcp-interceptor
```

Send data with netcat client
```
echo "test message" | nc localhost 8080
```
