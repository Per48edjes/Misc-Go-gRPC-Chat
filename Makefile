PROTO_DIR := proto
GO_OUT := gen/go
PY_OUT := gen/python
VENV_DIR := .venv
PROTOC_GEN_GO := $(shell go env GOPATH)/bin/protoc-gen-go
PROTOC_GEN_GO_GRPC := $(shell go env GOPATH)/bin/protoc-gen-go-grpc

.PHONY: all clean build-go build-python setup-python-venv setup-go-deps

all: build-go build-python

.PHONY: setup-go-deps
setup-go-deps:
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

build-go: setup-go-deps $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC)
	protoc $(PROTO_DIR)/*.proto --go_out=. --go_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat --go-grpc_out=. --go-grpc_opt=module=github.com/Per48edjes/Misc-Go-gRPC-Chat

build-python: setup-python-venv
	. $(VENV_DIR)/bin/activate && python -m grpc_tools.protoc -I$(PROTO_DIR) --python_out=$(PY_OUT) --grpc_python_out=$(PY_OUT) $(PROTO_DIR)/*.proto

clean:
	rm -f $(GO_OUT)/*.pb.go
	rm -f $(PY_OUT)/*_pb2.py
	rm -f $(PY_OUT)/*_pb2_grpc.py
