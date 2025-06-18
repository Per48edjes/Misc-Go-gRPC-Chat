# A Toy Go + gRPC Chat Service

A minimal chat application with a Go server and a Python client. 

Make sure `uv`, `python`, and `go` are installed -- running `make` in the project root should setup the project dependencies correctly:

```
$ make

Installing protoc-gen-go…
Installing protoc-gen-go-grpc…
Generating Go gRPC code…
Tidying up Go modules…
Installing Python dependencies…
Resolved 10 packages in 12ms
Audited 9 packages in 1ms
Generating Python gRPC code…
Fixing Python imports with Protoletariat…
Installing project as editable package…
Audited 1 package in 17ms

```

## Running the server

```bash
go run server.go
```

## Running the client

1. Create a virtual environment and install dependencies (requires `uv`). This installs `prompt_toolkit` which keeps the input line intact while messages are printed.

```bash
uv venv --project .
uv sync
```

2. Start the client:

```bash
. .venv/bin/activate
python client.py
```

Use `/quit` to exit the chat.
