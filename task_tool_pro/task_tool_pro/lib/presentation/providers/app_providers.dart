import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/blog_history_repository.dart';
import '../tools/video_downloader/video_downloader_view_model.dart';
import '../tools/ai_blog_generator/ai_blog_generator_view_model.dart';
import '../tools/blog_writer/blog_writer_view_model.dart';

final blogHistoryRepositoryProvider = Provider<BlogHistoryRepository>(
  (ref) => BlogHistoryRepository(),
);

final videoDownloaderViewModelProvider =
    ChangeNotifierProvider<VideoDownloaderViewModel>(
  (ref) => VideoDownloaderViewModel(),
);

final aiBlogGeneratorViewModelProvider =
    ChangeNotifierProvider<AiBlogGeneratorViewModel>(
  (ref) => AiBlogGeneratorViewModel(),
);

final blogWriterViewModelProvider =
    ChangeNotifierProvider<BlogWriterViewModel>(
  (ref) => BlogWriterViewModel(
    historyRepo: ref.read(blogHistoryRepositoryProvider),
  ),
);

