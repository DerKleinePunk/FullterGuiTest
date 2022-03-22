import 'http/websocket_client_stup.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerMessageClient {
  WebSocketChannel? channel; // =
  bool connected = false;

  ServerMessageClient(String server) {
    Uri serverUri = Uri.parse(server);
    String messageUri = "";
    if (serverUri.scheme == "https") {
      messageUri = "wss://";
    } else {
      messageUri = "ws://";
    }
    messageUri += serverUri.host;
    if (serverUri.port != 0) {
      messageUri += ":" + serverUri.port.toString();
    }
    messageUri += "/messages";
    channel = makeWsClient(messageUri);
    channel?.stream.listen((message) {
            print(message);
            if(message == "connected"){
              connected = true;
              print("Connection establised.");
            } else if(message == "send:success"){
              print("Message send success");
            } else if(message == "send:error"){
              print("Message send error");
            } else if (message.substring(0, 6) == "{'cmd'") {
              print("Message data");
              message = message.replaceAll(RegExp("'"), '"');
              //var jsondata = json.decode(message);
            }
          }, 
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          connected = false;
        },
        onError: (error) {
             print(error.toString());
        },);
  }

  void close() {
    channel?.sink.close();
  }
}
