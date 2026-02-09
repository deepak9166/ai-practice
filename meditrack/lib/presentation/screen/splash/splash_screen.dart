import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/svg_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    _setupBeforeStart();
    super.initState();
  }

  _setupBeforeStart() async {
    await Future.delayed(Duration(seconds: 1));
    AppRouter.go(context, AppConstants.routeLanding);

    return;
    var localStorageService = ref.read(localStorageServiceProvider);

    var userToken = await localStorageService.getAccessToken();

    // if ((userToken ?? "").isNotEmpty) {
    //   // ignore: use_build_context_synchronously
    //   AppRouter.go(context, AppConstants.routeLanding);
    // } else {
    //   // ignore: use_build_context_synchronously
    //   AppRouter.go(context, AppConstants.routeIntro);

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(child: SmartImageView(SvgImageId.ifLogo.path)),
    );
  }
}
