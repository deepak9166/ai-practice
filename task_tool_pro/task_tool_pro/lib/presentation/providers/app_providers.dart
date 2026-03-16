import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tools/video_downloader/video_downloader_view_model.dart';
import '../tools/ai_blog_generator/ai_blog_generator_view_model.dart';

final videoDownloaderViewModelProvider =
    ChangeNotifierProvider<VideoDownloaderViewModel>(
  (ref) => VideoDownloaderViewModel(),
);

final aiBlogGeneratorViewModelProvider =
    ChangeNotifierProvider<AiBlogGeneratorViewModel>(
  (ref) => AiBlogGeneratorViewModel(),
);

