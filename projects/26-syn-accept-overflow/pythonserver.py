import socket
import time

HOST, PORT, BACKLOG = "0.0.0.0", 8080, 5

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((HOST, PORT))
s.listen(BACKLOG)
print(f"listen {HOST}:{PORT} backlog={BACKLOG}")

RESP = b"HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok"

while True:
    time.sleep(1)
    conn, addr = s.accept()
    conn.sendall(RESP)
    conn.close()
    print("accept", addr)
