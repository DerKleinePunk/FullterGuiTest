import 'package:flutter/material.dart';
import 'package:mnehomeapp/core/client_helper.dart';
import 'package:mnehomeapp/core/extensions.dart';
import 'package:mnehomeapp/component/bootstrap/home_server_bootstrap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
  
}

class _DashboardState extends State<Dashboard> {
  List<MessageData> msglist = [];

  TextEditingController msgtext = TextEditingController();

  @override
  void initState() {
    msgtext.text = "";
    CoreClientHelper.getClient().addListener(_onWebSocketMessage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mobileMode = widget.renderMobileMode(context);
    return HomeServerBootstrap(() {
      String title = HomeServerLocalizations.of(context)!.titleDashboard;
      

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await CoreClientHelper.getClient().removeSessionIfExists();
                  await CoreClientHelper.clearAuthStorage();
                  await Navigator.of(context).pushReplacementNamed('dashboard');
                }),
          ],
        ),
        body: dashboardBody(),
        floatingActionButton: mobileMode
            ? FloatingActionButton(
                onPressed: () async {
                  /*final r = await showDatabaseAddDialog(context);
                  if (r != null) {
                    setState(() {
                      totalDbs?.add(r);
                    });
                  }*/
                },
                child: const Icon(Icons.add),
              )
            : null,
      );
    });
  }

  Widget? dashboardBody() {
    return Container(
        child: Stack(
      children: [
        Positioned(
            top: 0,
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
                padding: EdgeInsets.all(15),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Container(
                        child: Column(
                      children: msglist.map((onemsg) {
                        return Container(
                            margin: EdgeInsets.only(
                              //if is my message, then it has margin 40 at left
                              left: onemsg.isme ? 40 : 0,
                              right:
                                  onemsg.isme ? 0 : 40, //else margin at right
                            ),
                            child: Card(
                                color: onemsg.isme
                                    ? Colors.blue[100]
                                    : Colors.red[100],
                                //if its my message then, blue background else red background
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          child: Text(onemsg.isme
                                              ? "ID: ME"
                                              : "ID: " + onemsg.userid)),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                            "Message: " + onemsg.msgtext,
                                            style: TextStyle(fontSize: 17)),
                                      ),
                                    ],
                                  ),
                                )));
                      }).toList(),
                    ))
                  ],
                )))),
        Positioned(
          //position text field at bottom of screen

          bottom: 0, left: 0, right: 0,
          child: Container(
              color: Colors.black12,
              height: 70,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: msgtext,
                      decoration:
                          InputDecoration(hintText: "Enter your Message"),
                    ),
                  )),
                  Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        child: Icon(Icons.send),
                        onPressed: () {
                          if (msgtext.text != "") {
                            sendmsg(msgtext.text); //send message with webspcket
                            msgtext.text = "";
                          } else {
                            debugPrint("No Message no Send");
                          }
                        },
                      ))
                ],
              )),
        )
      ],
    ));
  }

  _onWebSocketMessage(String wath, String message) {
    debugPrint("Dashboard Websocket " + wath + " " + message);
    if (wath == "Text") {
      msglist.add(MessageData(message, "", false));
      setState(() {});
    }
  }

  @override
  void dispose() {
    CoreClientHelper.getClient().removeListener(_onWebSocketMessage);
    super.dispose();
  }

  void sendmsg(String text) {
    CoreClientHelper.getClient().sendMsg(text);
    msglist.add(MessageData(text, "", true));
  }
} // Class

class MessageData {
  //message data model
  String msgtext, userid;
  bool isme;
  MessageData(this.msgtext, this.userid, this.isme);
}
