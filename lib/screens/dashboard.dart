import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mnehomeapp/core/client_helper.dart';
import 'package:mnehomeapp/core/extensions.dart';
import 'package:mnehomeapp/component/bootstrap/home_server_bootstrap.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../component/widget/third_party/adaptive_scaffold.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _pageIndex = 0;
  final List<MessageData> _msglist = [];

  final TextEditingController _msgtext = TextEditingController();
  bool _isPlaying = false;
  
  @override
  void initState() {
    _msgtext.text = "";
    CoreClientHelper.getClient().addListener(_onWebSocketMessage);
    CoreClientHelper.getClient().addListnerPlayerState(_onPLayerState);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = HomeServerLocalizations.of(context)!.titleDashboard;
    return AdaptiveScaffold(
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.logout),
            onPressed:() async {
                  await CoreClientHelper.getClient().removeSessionIfExists();
                  await CoreClientHelper.clearAuthStorage();
                  await Navigator.of(context).pushReplacementNamed('dashboard');
                }
          ),
        ),
      ],
      currentIndex: _pageIndex,
      destinations: const [
        AdaptiveScaffoldDestination(title: 'Home', icon: Icons.home),
        AdaptiveScaffoldDestination(title: 'Entries', icon: Icons.list),
        AdaptiveScaffoldDestination(title: 'Settings', icon: Icons.settings),
      ],
      body: _pageAtIndex(_pageIndex),
      onNavigationIndexChange: (newIndex) {
        setState(() {
          _pageIndex = newIndex;
        });
      },
      floatingActionButton: null
          //_hasFloatingActionButton ? _buildFab(context) : null,
    );
  }

  Widget _pageAtIndex(int index) {
    if (index == 0) {
      return dashboardBody();
    }

    /*if (index == 1) {
      return const EntriesPage();
    }*/

    return const Center(child: Text('Settings page'));
  }

  /*@override
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
  }*/

  Widget dashboardBody() {
    return Stack(
      children: [
        Positioned(
            top: 0,
            bottom: 70,
            left: 0,
            right: 0,
            child: Container(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    Column(
                      children: _msglist.map((onemsg) {
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
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(onemsg.isme
                                          ? "ID: ME"
                                          : "ID: " + onemsg.userid),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Text(
                                            "Message: " + onemsg.msgtext,
                                            style:
                                                const TextStyle(fontSize: 17)),
                                      ),
                                    ],
                                  ),
                                )));
                      }).toList(),
                    )
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
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _msgtext,
                      decoration:
                          const InputDecoration(hintText: "Enter your Message"),
                    ),
                  )),
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          child: const Icon(Icons.send),
                          onPressed: () {
                            if (_msgtext.text != "") {
                              sendmsg(
                                  _msgtext.text); //send message with webspcket
                              _msgtext.text = "";
                            } else {
                              debugPrint("No Message no Send");
                            }
                          })),
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          child: Icon(!_isPlaying
                              ? Icons.play_circle
                              : Icons.stop_circle),
                          onPressed: () {
                            !_isPlaying ? _playAudio() : _pauseAudio();
                          }))
                ],
              )),
        )
      ],
    );
  }

  _onWebSocketMessage(String wath, String message) {
    debugPrint("Dashboard Websocket " + wath + " " + message);
    if (wath == "Text") {
      _msglist.add(MessageData(message, "", false));
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
    _msglist.add(MessageData(text, "", true));
  }

  void _playAudio() {
    CoreClientHelper.getClient().play("resources/musik.mp3");
  }

  void _pauseAudio() {
    //TODO Implement
  }

  void _onPLayerState(PlayerState state) {
    if (state == PlayerState.STOPPED) {
      _isPlaying = false;
      setState(() {});
    } else if (state == PlayerState.PLAYING) {
      _isPlaying = true;
      setState(() {});
    }
  }
} // Class

class MessageData {
  //message data model
  String msgtext, userid;
  bool isme;
  MessageData(this.msgtext, this.userid, this.isme);
}
