import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final AudioPlayer _player = AudioPlayer();
  static String? _currentTrack;
  static bool _isPlaying = false;

  static const List<Map<String, String>> builtInTracks = [
    {'id': 'lofi_rain', 'name': 'Lo-Fi Rain'},
    {'id': 'chill_lofi', 'name': 'Chill Lo-Fi'},
    {'id': 'sea_waves', 'name': 'Sea Waves'},
  ];

  static String? get currentTrack => _currentTrack;
  static bool get isPlaying => _isPlaying;

  static Future<void> playBuiltIn(String trackId) async {
    try {
      if (_currentTrack == trackId && _isPlaying) {
        await pause();
        return;
      }
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/$trackId.mp3'));
      _currentTrack = trackId;
      _isPlaying = true;
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
    }
  }

  static Future<void> playCustom(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      _currentTrack = path;
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  static Future<void> playCustomUrl(String url) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
      _currentTrack = url;
      _isPlaying = true;
    } catch (e) {
      _isPlaying = false;
    }
  }

  static Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  static Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _isPlaying = false;
  }

  static void dispose() {
    _player.dispose();
  }
}
