import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/language_keys.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../screen/base/screen_state_aware.dart';
import '../../providers/vm_provider.dart';
import '../../screen/base/base_consumer_state.dart';
import 'view_model/my_account_view_model.dart';

class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState
    extends BaseConsumerState<PrivacyPolicyScreen, MyAccountViewModel> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: viewModel.onPageStarted,
          onPageFinished: viewModel.onPageFinished,
        ),
      )
      ..loadRequest(Uri.parse(AppConstants.webPagePrivacyPolicyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LanguageKeys.privacyPolicy.tr()),
      body: ScreenStateAware.builder(
        state: viewModel.screenState,
        builder: (context) => WebViewWidget(controller: controller),
      ),
    );
  }

  @override
  MyAccountViewModel createViewModel() {
    return ref.read(myAccountViewModel);
  }

  @override
  String screenName() {
    return "Privacy Policy Screen";
  }

  @override
  void onModelReady(MyAccountViewModel model) {
    model.initStaticPage();
  }
}
