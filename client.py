import queue
import sys
import threading
import time
from typing import Generator

import grpc
from prompt_toolkit import PromptSession
from prompt_toolkit.patch_stdout import patch_stdout

from proto import chat_pb2, chat_pb2_grpc


def _request_generator(
    username: str, q: queue.Queue
) -> Generator[chat_pb2.ChatMessage, None, None]:
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


def _receive_messages(call) -> None:
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

    session = PromptSession()

    with grpc.insecure_channel("localhost:50051") as channel:
        try:
            grpc.channel_ready_future(channel).result(timeout=2)
        except grpc.FutureTimeoutError:
            print("Error: could not connect to chat server on localhost:50051.")
            sys.exit(1)

        stub = chat_pb2_grpc.ChatServiceStub(channel)
        call = stub.ChatStream(_request_generator(username, send_q))

        recv_thread = threading.Thread(
            target=_receive_messages, args=(call,), daemon=True
        )
        recv_thread.start()

        try:
            with patch_stdout():
                while True:
                    text = session.prompt("", multiline=False)
                    if text == "/quit":
                        break
                    send_q.put(text)
        except KeyboardInterrupt:
            print("KeyboardInterrupt received, exiting...")
        except Exception as e:
            print(f"unanticipated exception: {e}")
        finally:
            send_q.put(None)
            try:
                call.cancel()
            except Exception as e:
                print(f"Failed to cancel the call: {e}")
            recv_thread.join(timeout=2)
            if recv_thread.is_alive():
                print("Warning: recv_thread did not terminate within the timeout.")

    print("Disconnected")


if __name__ == "__main__":
    main()
