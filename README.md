# Misc Go gRPC Chat

A minimal chat application with a Go server and a Python client.

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
