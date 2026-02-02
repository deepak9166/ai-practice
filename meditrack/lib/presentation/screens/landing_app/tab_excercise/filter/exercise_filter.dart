import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/base/screen_state_aware.dart';
import 'package:meditrack/presentation/screens/landing_app/tab_excercise/filter/filter_view_model.dart';
import 'package:meditrack/presentation/screens/landing_app/tab_excercise/filter/mmg_msg_equpment_filter.dart';

import '../../../../../enum/filter_enum.dart' show FilterTypes;
import '../../../../providers/vm_provider.dart';
import 'template_type_filter.dart';

class ExerciseFilter extends ConsumerStatefulWidget {
  final Function(FilterTypes type) onSelectFilter;
  final List<FilterTypes> allowFilter;
  

  const ExerciseFilter({
    super.key,
    required this.onSelectFilter,
    required this.allowFilter,
  });

  @override
  ConsumerState<ExerciseFilter> createState() => _ExcerciseFilterState();
}

class _ExcerciseFilterState
    extends BaseConsumerState<ExerciseFilter, FilterViewModel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          SmartImageView(SvgImageId.filter.path),
          SizedBox(width: 10),
          Expanded(
            child: ScreenStateAware(
              state: viewModel.screenState,
              progress: ListView.separated(
                itemCount: 3,
                itemBuilder: (context, index) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 12),

                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(78),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSecondary,
                      width: 0.36,
                    ),
                  ),
                  onPressed: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 6),
                      Text('Loding'),
                      SmartImageView(SvgImageId.iconDownArrow.path),
                    ],
                  ),
                ),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
              ),
              builder: (context) => ListView.separated(
                itemCount: viewModel.filter.length,
                itemBuilder: (context, index) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.symmetric(horizontal: 12),

                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(78),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onSecondary,
                      width: 0.36,
                    ),
                  ),
                  onPressed: () {
                    appLog("Select filter : ${viewModel.filter[index].type}");
                    openFilterView(viewModel.filter[index].type, context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 6),
                      Text(viewModel.filter[index].name),
                      SmartImageView(SvgImageId.iconDownArrow.path),
                    ],
                  ),
                ),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(width: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openFilterView(FilterTypes type, BuildContext context) {
    switch (type) {
      case FilterTypes.mmg:
        showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          isScrollControlled: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 112,
          ),
          context: context,
          builder: (context) =>
              MmgFilter(heading: 'MMG', mmgList: viewModel.mmgLevelList),
        );
      case FilterTypes.msg:
        showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          isScrollControlled: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 112,
          ),
          context: context,
          builder: (context) => MmgFilter(
            heading: 'Muscle Sub-Group (MSG)',
            mmgList: viewModel.msgLevelList,
          ),
        );

      case FilterTypes.equipments:
        showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          isScrollControlled: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *.5,
          ),
          context: context,
          builder: (context) => MmgFilter(
            heading: 'Equipments',
            mmgList: viewModel.equipmentsLevelList,
          ),
        );
      case FilterTypes.templateType:
       showModalBottomSheet(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          isScrollControlled: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *.78,
          ),
          context: context,
          builder: (context) => TemplateTypeFilter(
            templateTypeList: viewModel.templateTypeList,
            heading: "Template Type",
          ),
        );
      case FilterTypes.customExcercise:
      // TODO: Handle this case.
    }
  }

  @override
  FilterViewModel createViewModel() {
    return ref.read(filterVm(widget.allowFilter));
  }

  @override
  String screenName() {
    return "Filter Screen";
  }
}
