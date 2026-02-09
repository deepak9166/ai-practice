import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/profile_qna/custom_value_picker_dialog.dart';
import 'package:meditrack/presentation/screens/profile_qna/profile_qna_stepper_widget.dart';

import 'profile_qna_data.dart';
import 'profile_qna_model.dart';

class ProfileQnaScreen extends StatelessWidget {
  ProfileQnaScreen({super.key});

  /// Tracks current step
  final ValueNotifier<int> currentIndex = ValueNotifier(0);

  /// Forces UI rebuild when model data changes
  final ValueNotifier<int> rebuildTrigger = ValueNotifier(0);

  ProfileQnaModel get currentQna => profileQnaList[currentIndex.value];

  void _refreshUI() {
    rebuildTrigger.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        automaticallyImplyLeading: false,
        title: Text(
          'My Fitness Goals',
          style: Theme.of(context).textTheme.labelLarge
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: rebuildTrigger,
        builder: (_, __, ___) {
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// STEP INDICATOR
                            Text(
                              'STEP ${currentQna.step}/${currentQna.totalSteps}',
                              style: Theme.of(context).textTheme.labelSmall
                            ),
                            VerticalSpacing.smallXs,
                            StepperDivider(
                              currentStep: currentQna.step,
                              totalSteps: currentQna.totalSteps,
                            ),
                            VerticalSpacing(size: 12),

                            Text(
                              'GOAL #${currentQna.step}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryFixedVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),

                            VerticalSpacing(size: 12),

                            /// TITLE
                            Text(
                              currentQna.title,
                              style: Theme.of(context).textTheme.titleLarge
                            ),

                            if (currentQna.description != null) ...[
                              const VerticalSpacing(size: 8),
                              Text(
                                currentQna.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                              ),
                            ],

                            const VerticalSpacing(size: 24),

                            if (currentQna.info?.isNotEmpty ?? false)
                              Column(
                                children: [
                                  Text(
                                    currentQna.info ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                  ),
                                  const VerticalSpacing(size: 10),
                                ],
                              ),

                            /// BODY
                            Flexible(child: _buildQnaBody()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentIndex.value == 0) return;
                        currentIndex.value--;
                        _refreshUI();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryFixedVariant
                                .withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryFixedVariant,
                        ),
                      ),
                    ),
                    HorizontalSpacing(size: 10),
                    GestureDetector(
                      onTap: () {
                        if (currentIndex.value == profileQnaList.length - 1) {
                          AppRouter.push(
                            context,
                            AppConstants.routeProfileQnAComplete,
                          );
                          return;
                        }
                        currentIndex.value++;
                        _refreshUI();
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSecondary,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.onPrimaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===================== BODY SWITCH =====================

  Widget _buildQnaBody() {
    switch (currentQna.type) {
      case QnaType.singleChoice:
        return _buildSingleChoice();
      case QnaType.input:
        return _buildInput();
      case QnaType.percentage:
        return _buildPercentage();
      default:
        return const VerticalSpacing();
    }
  }

  // ===================== SINGLE CHOICE =====================

  Widget _buildSingleChoice() {
    return ListView.separated(
      itemCount: currentQna.options!.length,
      separatorBuilder: (_, __) => const VerticalSpacing(size: 12),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final option = currentQna.options![index];
        final isSelected = currentQna.value == option.value;

        return InkWell(
          onTap: () {
            currentQna.value = option.value;
            _refreshUI();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.inverseSurface
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryFixed
                      : Theme.of(context).colorScheme.onSecondary,
                ),
                const HorizontalSpacing(size: 12),
                Expanded(
                  child: Text(
                    option.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryFixed
                          : Theme.of(context).colorScheme.onSecondary,
        
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== INPUT =====================
  Widget _buildInput() {
    final displayValue = currentQna.value != null
        ? currentQna.value.toString()
        : '';

    return GestureDetector(
      onTap: () {
        CustomValuePickerDialog.show(
          context: navigatorKey.currentContext!,
          title: currentQna.hintText ?? 'Select',
          mainValues: _getMainValues(),
          decimalValues: List.generate(100, (i) => i),
          // 00–99
          units: _getUnits(),
          initialMainValue: 70,
          onSave: (value) {
            currentQna.value = value;
            _refreshUI();
          },
        );
      },
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(
            navigatorKey.currentContext!,
          ).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayValue.isEmpty ? currentQna.hintText! : displayValue,
          style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium
              ?.copyWith(
                color: displayValue.isEmpty
                    ? Theme.of(
                        navigatorKey.currentContext!,
                      ).colorScheme.onSecondaryFixedVariant
                    : Theme.of(
                        navigatorKey.currentContext!,
                      ).colorScheme.onSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }

  List<int> _getMainValues() {
    switch (currentQna.unit) {
      case 'kg':
        return List.generate(100, (i) => 40 + i);
      case '%':
        return List.generate(60, (i) => 5 + i);
      case 'cm':
        return List.generate(80, (i) => 50 + i);
      default:
        return List.generate(100, (i) => i);
    }
  }

  List<String> _getUnits() {
    switch (currentQna.unit) {
      case 'kg':
        return ['kg', 'lb'];
      case '%':
        return ['%'];
      case 'cm':
        return ['cm'];
      default:
        return [''];
    }
  }

  // ===================== PERCENTAGE =====================

  Widget _buildPercentage() {
    return ListView.separated(
      itemCount: currentQna.options!.length,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const VerticalSpacing(size: 12),
      itemBuilder: (context, index) {
        final option = currentQna.options![index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  option.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '%',
                    suffixText: '%',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    option.value = int.tryParse(value) ?? 0;
                    _refreshUI();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
