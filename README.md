# TCP proxy

Simple TCP proxy written in OCaml and Core Unix library

## How to run

Install dependencies
```
esy install
```

Start new netcat server
```
nc -l -p 8081
```

Start the proxy
```
esy x tcp-proxy
```

Send data with netcat client
```
echo "test message" | nc localhost 8080
```
