import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/package/bottom_navigation/stylish_bottom_bar.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';

import 'add_medicine/add_medicine_screen.dart';
import 'landing_view_model.dart';
import 'tab1_home/home_screen.dart';
import 'tab2_medicines/medicines_list_screen.dart';
import 'tab3_expenses/expenses_screen.dart';
import 'tab4_history/history_screen.dart';

/// Home Screen
///
/// Main screen displayed after successful authentication.
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState
    extends BaseConsumerState<LandingScreen, LandingViewModel> {
  @override
  LandingViewModel createViewModel() {
    return ref.read(homeViewModel);
  }

  int? selected = 0;
  bool heart = false;
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isCenterSelected = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageProvider);

    appLog(locale.countryCode);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      
      body: SafeArea(
        top: false,
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [
            HomeScreen(),
            MedicinesListScreen(),
            ExpensesScreen(),
            HistoryScreen(),
            AddMedicineScreen(), // Center plus button screen
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Builder(
        builder: (contextScafold) => FloatingActionButton(
          elevation: 5,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () {
            controller.jumpToPage(4);
            setState(() {
              isCenterSelected = true;
              selected = null;
            });
          },
          backgroundColor: isCenterSelected
              ? Theme.of(context).primaryColor
              : Colors.black,
          child: Icon(CupertinoIcons.plus, color: Colors.white),
        ),
      ),
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
          iconSize: 10,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.Default,
        ),
        items: [
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuHome.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedHome.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'Home',
          ),
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuExcercise.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedExcercise.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'Medicines',
          ),
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuProgress.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedProgress.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'Expanses',
          ),
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuTemplate.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedTemplate.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'History',
          ),
        ],
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        currentIndex: selected,
        notchStyle: NotchStyle.circle,

        elevation: 10,
        iconSpace: 10,
        onTap: (index) {
          if (index == selected) return;
          controller.jumpToPage(index);
          setState(() {
            selected = index;
            isCenterSelected = false;
          });
        },
      ),
    );
  }

  @override
  String screenName() {
    return "Home Screen";
  }
}
