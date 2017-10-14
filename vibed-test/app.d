import std.stdio;
import std.socket;
import vibe.vibe;

static HTTPServerSettings settings;

void main()
{
  writeln("start...");
  auto socket = new TcpSocket;
  socket.bind(new InternetAddress("127.0.0.1", 0));
  auto addr1 = socket.localAddress();
  writeln(addr1.toString);
  socket.close();

  listenHTTP(addr1.toString, &handleRequest);
  runApplication();
}

void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
{
  if (req.path == "/")
    res.writeBody("Hello, World!");
}
