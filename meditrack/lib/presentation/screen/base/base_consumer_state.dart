import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

abstract class BaseConsumerState<T extends ConsumerStatefulWidget,
    V extends BaseViewModel> extends ConsumerState<T> {
  late final V viewModel;

  String screenName();

  V createViewModel();

  void onModelReady(V model) {}

  bool isBottomSheet() => false;

  @override
  void initState() {
    super.initState();
    viewModel = createViewModel();
    onModelReady(viewModel);
  }

  void showMessage(String message) {

  }

  void showErrorMessage(String message) {

  }
}