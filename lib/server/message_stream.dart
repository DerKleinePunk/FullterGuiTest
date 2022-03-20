import 'http/websocket_client_stup.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerMessageClient {
  WebSocketChannel? channel; // =

  ServerMessageClient(String server) {
    Uri serverUri = Uri.parse(server);
    String messageUri = "";
    if (serverUri.scheme == "https") {
      messageUri = "wss://";
    } else {
      messageUri = "ws://";
    }
    messageUri += serverUri.host;
    if(serverUri.port != 0){
       messageUri += ":" + serverUri.port.toString();
    }
    messageUri += "/messages";
    channel = makeWsClient(messageUri);
  }
}
