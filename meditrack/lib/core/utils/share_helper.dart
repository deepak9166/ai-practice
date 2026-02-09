import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static shareMessage(String message) {
    SharePlus.instance.share(ShareParams(text: "Shared text"));
  }
}
