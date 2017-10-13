import std.stdio;
import std.socket;
import vibe.vibe;

static HTTPServerSettings settings;

void main()
{
        writeln("start...");
  auto serverTcpSocket = new TcpSocket;
  serverTcpSocket.bind(new InternetAddress("127.0.0.1", 0));
    auto addr1 = serverTcpSocket.localAddress();
    writeln(addr1.toString);
serverTcpSocket.close();
    //auto addr2 = serverTcpSocket.remoteAddress();
    //writeln(addr2.toString);
    //Socket server = new TcpSocket();
    //server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    //server.bind(new InternetAddress(0));
    //auto addr1 = server.createAddress();
    //writeln(addr1.port);

        //auto addr = new InternetAddress("127.0.0.1", 0u);
        //writeln(addr.port);
	//auto settings = new HTTPServerSettings;
	//settings = new HTTPServerSettings;
	//settings.port = 8084;
	//settings.port = 0;
	//settings.port = addr.port;
	//settings.bindAddresses = ["::1", "127.0.0.1"];
	//HTTPListener hl = listenHTTP(settings, &handleRequest);
        //writefln("port=%u", settings.port);
        //writefln("port=%d", settings.port);
	//listenHTTP("127.0.0.1:8080", &handleRequest);
	listenHTTP(addr1.toString, &handleRequest);
	//runApplication();
}

void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
{
	if (req.path == "/")
		res.writeBody("Hello, World!");
}
