import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/video_downloader/video_downloader_view_model.dart';

final videoDownloaderViewModelProvider =
    ChangeNotifierProvider<VideoDownloaderViewModel>(
  (ref) => VideoDownloaderViewModel(),
);

