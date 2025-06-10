package main

import (
	"log"
	"net"
	"sync"

	pb "github.com/Per48edjes/Misc-Go-gRPC-Chat/gen/go" // protobuf package
	"google.golang.org/grpc"
)

type ChatServer struct {
	pb.UnimplementedChatServiceServer

	mu      sync.Mutex
	clients map[int64]chan *pb.ChatMessage
	nextID  int64
}

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterChatServiceServer(grpcServer, NewChatServer())

	log.Println("server listening at :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func NewChatServer() *ChatServer {
	return &ChatServer{
		clients: make(map[int64]chan *pb.ChatMessage),
	}
}

func (s *ChatServer) ChatStream(stream pb.ChatService_ChatStreamServer) error {
	id, ch := s.registerClient()
	defer s.unregisterClient(id)

	// Receive messages from this client in a separate goroutine
	go func() {
		for {
			msg, err := stream.Recv()
			// stream.Recv() returns io.EOF when the client closes
			if err != nil {
				break
			}
			s.broadcast(msg)
		}
	}()

	// Send messages to the client
	for msg := range ch {
		if err := stream.Send(msg); err != nil {
			break
		}
	}
	return nil
}

// Helper functions for client interaction
func (s *ChatServer) registerClient() (int64, chan *pb.ChatMessage) {
	s.mu.Lock()
	defer s.mu.Unlock()

	ch := make(chan *pb.ChatMessage, 10)
	s.nextID++
	s.clients[s.nextID] = ch
	return s.nextID, ch
}

func (s *ChatServer) unregisterClient(id int64) {
	s.mu.Lock()

	ch := s.clients[id]
	delete(s.clients, id)

	s.mu.Unlock()
	close(ch)
}

func (s *ChatServer) broadcast(msg *pb.ChatMessage) {
	s.mu.Lock()
	defer s.mu.Unlock()

	for _, ch := range s.clients {
		ch <- msg
	}
}
