import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import '../server/client.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  final ServerClient _serverClient;
  late AudioPlayer _audioPlayer;
  late AudioPlayer _audioPlayerNotification;
  //late AudioCache _audioCache;
  int _maxduration = 0;
  int _currentDuration = 0;
  int _maxdurationNotification = 0;
  int _currentDurationNotification = 0;

  AudioPlayerService(this._serverClient);

  init() {
    _serverClient.addListener(_onWebSocketMessage);
    _audioPlayer = AudioPlayer(
        mode: PlayerMode.MEDIA_PLAYER, playerId: 'mneHomeAppPLayer');
    _audioPlayerNotification = AudioPlayer(
        mode: PlayerMode.MEDIA_PLAYER,
        playerId: 'mneHomeAppPLayerNotification');
    _audioPlayer
        .setReleaseMode(ReleaseMode.STOP); // set release mode so that it never
    //_audioCache = AudioCache(fixedPlayer: _audioPlayerNotification);
    if (!kIsWeb) {
      // Calls to Platform.isIOS fails on web
      if (Platform.isIOS) {
        //_audioCache.fixedPlayer?.notificationService.startHeadlessService();
      }
    }
    Logger.changeLogLevel(LogLevel.INFO);

    _audioPlayer.onDurationChanged.listen((Duration d) {
      _maxduration = d.inMilliseconds;
      debugPrint("_maxduration " + _maxduration.toString());
    });

    _audioPlayer.onAudioPositionChanged.listen((Duration d) {
      _currentDuration = d.inMilliseconds;
      _updateDuration();
    });

    _audioPlayerNotification.onAudioPositionChanged.listen((Duration d) {
      _currentDurationNotification = d.inMilliseconds;
      _updateDurationNotification();
    });

    _audioPlayer.onPlayerStateChanged
        .listen((PlayerState s) => {debugPrint('Current player state: $s')});

    _audioPlayer.onPlayerCompletion.listen((event) {
      debugPrint("PlayerCompletion");
    });

    _audioPlayer.onPlayerError.listen((msg) {
      debugPrint('audioPlayer error : $msg');
    });

    _audioPlayerNotification.onPlayerError.listen((msg) {
      debugPrint('audioPlayerNotification error : $msg');
    });
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

    if (_audioPlayer.state == PlayerState.PLAYING) {
      _audioPlayer.setVolume(0.5);
    }

    /*_audioCache.play("http://localhost:8000/rainforest-ambient.mp3",
        isNotification: true);*/
    int result = await _audioPlayerNotification
        .setUrl("http://localhost:8000/rainforest-ambient.mp3");
    if (result == 1) {
      debugPrint("Sound loading successfull");
    } else {
      debugPrint("Error loading sound");
    }

    _maxdurationNotification = 0;
    result = await _audioPlayerNotification.resume();
    if (result == 1) {
      debugPrint("Sound playing successfull");
    } else {
      debugPrint("Error while playing sound");
    }

    debugPrint("playing sound notification");
  }

  void play(String audioFile) async {
    int result = await _audioPlayer.setUrl(audioFile);
    if (result == 1) {
      debugPrint("Sound loading successfull");
    } else {
      debugPrint("Error loading sound");
    }

    _maxduration = 0;
    _audioPlayer.setVolume(1);
    result = await _audioPlayer.resume();
    if (result == 1) {
      debugPrint("Sound playing successfull");
    } else {
      debugPrint("Error while playing sound");
    }
  }

  void dispose() {
    //_audioPlayer.stop();
    _audioPlayer.dispose();
    //_audioPlayerNotification.stop();
    _audioPlayerNotification.dispose();
  }

  void _updateDuration() async {
    if (_maxduration == 0) {
      _maxduration = await _audioPlayer.getDuration();
    }
    double ready = ((_currentDuration / _maxduration) * 100);
    debugPrint("played " + ready.toString());
    if (ready == 100) {
      //_audioPlayer.stop();
    }
  }

  void _updateDurationNotification() async {
    if (_maxdurationNotification == 0) {
      _maxdurationNotification = await _audioPlayerNotification.getDuration();
    }
    double ready =
        ((_currentDurationNotification / _maxdurationNotification) * 100);
    debugPrint("played Notification " + ready.toString());
    if (ready == 100) {
      await _audioPlayerNotification.stop();
      if (_audioPlayer.state == PlayerState.PLAYING) {
        _audioPlayer.setVolume(1);
      }
    }
  }
}
