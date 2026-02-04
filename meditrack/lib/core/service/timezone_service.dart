import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeZoneHelper {
  static Future<void> init() async {
    tz.initializeTimeZones();
   tz.setLocalLocation(tz.local); // ✅ DO THIS
  }
}