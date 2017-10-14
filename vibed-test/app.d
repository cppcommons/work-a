import std.stdio;
import std.socket;
import vibe.vibe;

static HTTPServerSettings settings;

unittest{
    assert(1+2 == 3);
    auto arr = [1, 2, 3];
    assert(arr.length == 4); // 間違ってるけど Emacs が教えてくれる！
}

version(unittest) {}
else
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

class Sum
{
    int add(int x, int y) { return x + y; }

    unittest
    {
        Sum sum = new Sum;
        assert(sum.add(3,4) == 7);
        assert(sum.add(-2,0) == -2);
        assert(sum.add(-2,0) == -1);
    }
}
