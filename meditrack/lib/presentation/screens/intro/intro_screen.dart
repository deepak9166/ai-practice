import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/core/constants/language_keys.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../common_widgets/rich_text_title.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();

  ValueNotifier<int> currentPageIndex = ValueNotifier(0);
  List introPages = [
    {
      "title": LanguageKeys.yourJourney.tr(),
      "richTitle": LanguageKeys.youStartsHere.tr(),
      "description":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    },
    {
      "title": "Workouts Made Simple, ",
      "richTitle": "Progress to Made Real",
      "description":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    },
    {
      "title": "Crush Your Goals, ",
      "richTitle": "One Workout at a Time",
      "description":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          SizedBox(
            height: 32,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                side: BorderSide(color: Theme.of(context).colorScheme.onSecondary),
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: () {
                AppRouter.go(context, AppConstants.routeSignUp);
              },
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: currentPageIndex,
                    builder: (context, value, child) {
                      return (introPages.length - 1) == value
                          ? Text("Continue")
                          : Text("Skip");
                    },
                  ),
                  SizedBox(width: 4),
                  SmartImageView(SvgImageId.arrowLeft.path),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: PageView.builder(
      
        itemCount: introPages.length,
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (value) {
          currentPageIndex.value = value;
        },
        itemBuilder: (context, index) {
          var item = introPages[index];
          return SizedBox(
            child: Column(
              children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: RichTextTitle(
                  description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                  title1: item['title'],
                  title2: item['richTitle'],
                ),
              ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 30,
                    ),
                    child: InkWell(
                      onTap: () {
                        if ((introPages.length - 1) == currentPageIndex.value) {
                          // On last page
                          AppRouter.go(context, AppConstants.routeSignUp);
                        } else {
                          _pageController.animateToPage(
                            currentPageIndex.value + 1,
                            curve: Curves.ease,
                            duration: Duration(milliseconds: 500),
                          );
                        }
                      },
                      child: SmartImageView(SvgImageId.arrowRightButton.path),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(30),
                  child: SmartImageView(PngImageId.introGraph.path),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SmoothPageIndicator(
        controller: _pageController, // PageController
        count: 3,
        effect: WormEffect(
          dotHeight: 10,
          dotWidth: 10,
          dotColor: Theme.of(context).colorScheme.secondary,
          activeDotColor: Theme.of(context).colorScheme.onSecondary,
        ), // your preferred effect
        onDotClicked: (index) {
          _pageController.animateToPage(
            index,
            curve: Curves.ease,
            duration: Duration(milliseconds: 500),
          );
        },
      ),
    );
  }
}
