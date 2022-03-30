import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import '../server/client.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  final ServerClient _serverClient;
  late AudioPlayer _audioPlayer;
  late AudioCache _audioCache;
  int _maxduration = 0;
  AudioPlayerService(this._serverClient);

  init() {
    _serverClient.addListener(_onWebSocketMessage);
    _audioPlayer = AudioPlayer(
        mode: PlayerMode.MEDIA_PLAYER, playerId: 'mneHomeAppPLayer');
    _audioPlayer
        .setReleaseMode(ReleaseMode.STOP); // set release mode so that it never
    _audioCache = AudioCache(fixedPlayer: _audioPlayer);
    if (!kIsWeb) {
      // Calls to Platform.isIOS fails on web
      if (Platform.isIOS) {
        _audioCache.fixedPlayer?.notificationService.startHeadlessService();
      }
    }
    Logger.changeLogLevel(LogLevel.INFO);

    _audioPlayer.onDurationChanged.listen((Duration d) {
      _maxduration = d.inMilliseconds;
      debugPrint("_maxduration " + _maxduration.toString());
    });

    _audioPlayer.onPlayerStateChanged
        .listen((PlayerState s) => {debugPrint('Current player state: $s')});
  }

  void _onWebSocketMessage(String wath, String message) {
    debugPrint("AudioPlayerService Websocket " + wath + " " + message);
    if (wath == "data") {
      var jsondata = jsonDecode(message);
      if (jsondata["action"] == "playSound") {
        _playNotification();
      }
    }
  }

  void _playNotification() async {
    //final uri = await _audioCache.load('');
    /*int result = await _audioPlayer
        .setUrl('http://localhost:8000/rainforest-ambient.mp3');
    if (result == 1) {
      debugPrint("Sound loading successfull");
    } else {
      debugPrint("Error loading sound");
    }
    result = await _audioPlayer.resume();
    if (result == 1) {
      debugPrint("Sound playing successfull");
    } else {
      debugPrint("Error while playing sound");
    }*/

    _audioCache.play("http://localhost:8000/rainforest-ambient.mp3",
        isNotification: true);
  }

  void play(String audioFile) async {
    int result = await _audioPlayer.setUrl(audioFile);
    if (result == 1) {
      debugPrint("Sound loading successfull");
    } else {
      debugPrint("Error loading sound");
    }
    result = await _audioPlayer.resume();
    if (result == 1) {
      debugPrint("Sound playing successfull");
    } else {
      debugPrint("Error while playing sound");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
