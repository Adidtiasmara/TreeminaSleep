import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final AudioPlayer _player = AudioPlayer();
  static String? _currentTrack;
  static bool _isPlaying = false;

  static const List<Map<String, String>> builtInTracks = [
    {'id': 'ocean_waves', 'name': 'Ocean Waves', 'icon': '🌊'},
    {'id': 'rainy_night', 'name': 'Rainy Night', 'icon': '🌧️'},
    {'id': 'calm_piano', 'name': 'Calm Piano', 'icon': '🎹'},
    {'id': 'forest_breeze', 'name': 'Forest Breeze', 'icon': '🌲'},
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
      // Karena tidak ada file audio sungguhan, kita simulasikan
      // Pada implementasi nyata, gunakan: await _player.play(AssetSource('audio/$trackId.mp3'));
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
