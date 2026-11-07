import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  /// Plays a notification sound when a task is updated
  static Future<void> playNotificationSound() async {
    try {
      _player.audioCache.prefix = 'Assets/';
      await _player.stop();
      await _player.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      debugPrint('Error playing notification sound (mp3): $e');
      try {
        await _player.play(AssetSource('sounds/notification.wav'));
      } catch (e2) {
        debugPrint('Error playing notification sound fallback (wav): $e2');
      }
    }
  }
}
