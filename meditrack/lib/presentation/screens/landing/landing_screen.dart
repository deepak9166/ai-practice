import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/package/bottom_navigation/stylish_bottom_bar.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/add_workout.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/templates/workout_templates_screen.dart';
import 'tab_excercise/excercise_screen.dart';
import 'tab_home/home_screen.dart';
import 'landing_view_model.dart';
import 'tab_my_progress/my_progress_screen.dart';

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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [
            HomeScreen(),
            ExcerciseScreen(),
            MyProgressScreen(),
            WorkoutTemplatesScreen(),
            AddWorkoutScreen(), // Center plus button screen
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
          backgroundColor: isCenterSelected ? Theme.of(context).primaryColor : Colors.black,
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
            title: 'Exercise',
          ),
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuProgress.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedProgress.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'My Progress',
          ),
          BottomBarItem(
            icon: SmartImageView(SvgImageId.menuTemplate.path),
            selectedIcon: SmartImageView(SvgImageId.menuSelectedTemplate.path),
            selectedColor: Theme.of(context).colorScheme.primary,
            unSelectedColor: Theme.of(
              context,
            ).colorScheme.onSecondaryFixedVariant,
            title: 'Templates',
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
