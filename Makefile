PROTO_DIR := proto
VENV_DIR := .venv
PROTOC_GEN_GO := $(shell go env GOPATH)/bin/protoc-gen-go
PROTOC_GEN_GO_GRPC := $(shell go env GOPATH)/bin/protoc-gen-go-grpc

.PHONY: all clean build-go build-python

# WARN: Run from project root directory!
all: build-go build-python

install-go-protoc-plugins:
	@echo "Installing protoc-gen-go…"
	@go install google.golang.org/protobuf/cmd/protoc-gen-go
	@echo "Installing protoc-gen-go-grpc…"
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc

build-go: install-go-protoc-plugins
	@echo "Generating Go gRPC code…"
	@protoc $(PROTO_DIR)/*.proto --go_out=$(PROTO_DIR) --go_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat --go-grpc_out=$(PROTO_DIR) --go-grpc_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat
	@echo "Tidying up Go modules…"
	@go mod tidy


$(VENV_DIR)/bin/activate: pyproject.toml
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment…"; \
		uv venv --project .; \
	fi
	@echo "Installing Python dependencies…"; \
	uv sync --locked;


setup-python-venv: $(VENV_DIR)/bin/activate

build-python: setup-python-venv
	@. $(VENV_DIR)/bin/activate && { \
	  echo "Generating Python gRPC code…"; \
	  python -m grpc_tools.protoc -I$(PROTO_DIR) \
	    --python_out=$(PROTO_DIR) \
	    --grpc_python_out=$(PROTO_DIR) \
	    $(PROTO_DIR)/*.proto; \
	  echo "Fixing Python imports with Protoletariat…"; \
	  protol --create-package --in-place \
	    --python-out $(PROTO_DIR) \
	    protoc --proto-path=$(PROTO_DIR) $(PROTO_DIR)/*.proto; \
	  echo "Installing project as editable package…"; \
	  uv pip install --editable .; \
	}

clean:
	rm -f $(PROTO_DIR)/*.pb.go
	rm -f $(PROTO_DIR)/*_pb2.py
	rm -f $(PROTO_DIR)/*_pb2_grpc.py
