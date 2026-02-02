import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';

import '../../../common_model/radio_value_model.dart';
import '../../../common_widgets/custom_bottom_sheet_field.dart';
import '../../../common_widgets/custom_radio_button_list.dart';
import '../../../providers/vm_provider.dart';
import 'mmg_level_card.dart';
import 'mmg_level_list.dart';
import 'mmg_level_view_model.dart';

class SelectMMGLevel extends ConsumerStatefulWidget {
  final bool isForEdit;
  const SelectMMGLevel({super.key, required this.isForEdit});

  @override
  ConsumerState<SelectMMGLevel> createState() => _SelectMMGLevelState();
}

class _SelectMMGLevelState
    extends BaseConsumerState<SelectMMGLevel, MmgLevelViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isForEdit  ?  'MMG' :'Preferred MMG Level'), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalSpacing.small,
            Text("Select Tier", style: Theme.of(context).textTheme.titleMedium),
            VerticalSpacing.small,
            CustomRadioButtonList(
              options: [
                RadioValueModel(title: "Tier 1", value: 'tier1'),
                RadioValueModel(title: "Tier 2", value: 'tier2'),
              ],
              onChanged: (size) {
                // Update your cart or form
              },
            ),
            VerticalSpacing.small,

            ValueListenableBuilder(
              valueListenable: viewModel.selectItemIndex,
              builder: (context, value, child) {
                var item = value != -1 ? viewModel.mmgLevelList[value] : null;
                return CustomBottomSheetField(
                  label: 'Select MMG Level',
                  hint: 'Select MMG Level',
                  tooltip: ' in development', // TODO:
                  selectedValue: item != null
                      ? MMGLevelSelectedCard(
                          title: item.title,
                          description: item.description,
                          imageUrl: item.image,
                        )
                      : null,
                  onSelectIndex: (callbackValue) {
                    if (callbackValue != null) {
                      viewModel.selectItemIndex.value = callbackValue;
                    }
                  },

                  builder: (ctx) {
                    return MMGLevelList(mmgLevelList: viewModel.mmgLevelList);
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                AppRouter.go(context, AppConstants.profileSetupSuccess);
              },
              child: Text('SAVE PREFERENCE'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  MmgLevelViewModel createViewModel() {
    return ref.read(mmgLevelViewModel);
  }

  @override
  String screenName() {
    return "MMG LEVEL PAGE";
  }
}
