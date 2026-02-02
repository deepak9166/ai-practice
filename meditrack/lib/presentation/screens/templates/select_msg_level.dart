import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screens/add_workout/common_widgets/slider_container.dart';
import 'package:meditrack/presentation/screens/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class SelectMsgLevelScreen extends ConsumerStatefulWidget {
  const SelectMsgLevelScreen({super.key});

  @override
  ConsumerState<SelectMsgLevelScreen> createState() =>
      _SelectMsgLevelScreenState();
}

class _SelectMsgLevelScreenState
    extends BaseConsumerState<SelectMsgLevelScreen, TemplatesViewModel> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Select MSG Level'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<List<double>>(
                valueListenable: viewModel.mmgValues,
                builder: (context, values, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: TemplatesViewModel.titles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: SliderContainer(
                          title: TemplatesViewModel.titles[index],
                          value: values[index],
                          onChanged: (value) {
                            final newValues = List<double>.from(values);
                            newValues[index] = value;
                            viewModel.mmgValues.value = newValues;
                          },
                          min: 0.0,
                          max: 1.0,
                          divisions: 20,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                text: 'SAVE',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  TemplatesViewModel createViewModel() {
    return ref.read(templatesViewModelProvider);
  }

  @override
  String screenName() {
    return "Select MSG Level Screen";
  }
}
