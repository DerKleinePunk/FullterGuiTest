class HomeServerEndpoints {
  static const String websocket = '';
  static const String session = 'api/session';

  static Uri combine(String path1, String path2) {
    return Uri.parse('$path1/$path2');
  }
}