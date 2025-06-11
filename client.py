import queue
import threading
import time

import grpc

from proto import chat_pb2, chat_pb2_grpc


def _request_generator(username: str, q: queue.Queue):
    """Yield ChatMessage objects from the queue."""
    while True:
        message = q.get()
        if message is None:
            break
        yield chat_pb2.ChatMessage(
            user=username,
            message=message,
            timestamp=int(time.time()),
        )


def _receive_messages(call):
    """Print messages received from the server."""
    try:
        for msg in call:
            ts = time.strftime("%H:%M:%S", time.localtime(msg.timestamp))
            print(f"[{ts}] {msg.user}: {msg.message}")
    except grpc.RpcError as e:
        print(f"stream closed: {e}")


def main() -> None:
    username = input("Enter username: ").strip() or "anon"
    send_q: queue.Queue[str | None] = queue.Queue()

    with grpc.insecure_channel("localhost:50051") as channel:
        stub = chat_pb2_grpc.ChatServiceStub(channel)
        call = stub.ChatStream(_request_generator(username, send_q))

        recv_thread = threading.Thread(
            target=_receive_messages, args=(call,), daemon=True
        )
        recv_thread.start()

        try:
            while True:
                text = input()
                if text == "/quit":
                    break
                send_q.put(text)
        finally:
            send_q.put(None)
            recv_thread.join()

    print("Disconnected")


if __name__ == "__main__":
    main()
