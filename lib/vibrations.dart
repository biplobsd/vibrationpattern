import 'package:vibration/vibration.dart';

import 'shared_preferences_helper.dart';

class Vibrations {
  static Future<void> play(channelKey) async {
    if (await Vibration.hasVibrator() ?? false) {
      final value = await SharedPreferencesHelper.loadMap(channelKey);
      if (value == null) return;
      final pattern = value['pattern'] ?? [];
      final intensities = value['intensities'] ?? [];
      Vibration.vibrate(
        pattern: pattern,
        intensities: intensities,
      );
    }
  }

  static Future<void> cancel() async {
    await Vibration.cancel();
  }

  static Future<void> trigger(String channelKey, [bool start = true]) async {
    if (start) {
      await play(channelKey);
    } else {
      await cancel();
    }
  }
}
