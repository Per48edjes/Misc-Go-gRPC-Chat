PROTO_DIR := proto
VENV_DIR := .venv
PROTOC_GEN_GO := $(shell go env GOPATH)/bin/protoc-gen-go
PROTOC_GEN_GO_GRPC := $(shell go env GOPATH)/bin/protoc-gen-go-grpc

.PHONY: all clean build-go build-python setup-python-venv setup-go-deps

# WARN: Run from project root directory!
all: setup-go-deps build-python

.PHONY: setup-go-deps
setup-go-deps: build-go
	go mod tidy
	@echo "Installing protoc-gen-go (pinned)…"
	go install google.golang.org/protobuf/cmd/protoc-gen-go
	@echo "Installing protoc-gen-go-grpc (pinned)…"
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc

setup-python-venv: $(VENV_DIR)/bin/activate

$(VENV_DIR)/bin/activate: pyproject.toml
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment..."; \
		uv venv --project .; \
	fi
	@echo "Installing Python dependencies..."; \
		uv sync --locked; \

build-go: $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC)
	protoc $(PROTO_DIR)/*.proto --go_out=$(PROTO_DIR) --go_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat --go-grpc_out=$(PROTO_DIR) --go-grpc_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat

build-python: setup-python-venv
	@echo "Building Python code..."
	. $(VENV_DIR)/bin/activate && \
	  echo "Generating Python gRPC code…" && \
	  python -m grpc_tools.protoc -I$(PROTO_DIR) \
	    --python_out=$(PROTO_DIR) \
	    --grpc_python_out=$(PROTO_DIR) \
	    $(PROTO_DIR)/*.proto && \
	  echo "Fixing Python imports with Protoletariat…" && \
	  protol --create-package --in-place \
	    --python-out $(PROTO_DIR) \
	    protoc --proto-path=$(PROTO_DIR) $(PROTO_DIR)/*.proto && \
	  echo "Installing project as editable package…" && \
	  uv pip install --editable .

clean:
	rm -f $(PROTO_DIR)/*.pb.go
	rm -f $(PROTO_DIR)/*_pb2.py
	rm -f $(PROTO_DIR)/*_pb2_grpc.py
