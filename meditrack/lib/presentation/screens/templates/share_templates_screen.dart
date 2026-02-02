import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/share_templates_wiget.dart';
import 'package:meditrack/presentation/screens/templates/view_model/templates_viewmodel.dart';

class ShareTemplatesScreen extends ConsumerStatefulWidget {
  const ShareTemplatesScreen({super.key});

  @override
  ConsumerState<ShareTemplatesScreen> createState() =>
      _ShareTemplatesScreenState();
}

class _ShareTemplatesScreenState
    extends BaseConsumerState<ShareTemplatesScreen, TemplatesViewModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Share Templates'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: viewModel.usersShare,
                  builder: (context, value, child) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final user = value[index];
                        return ShareTemplatesWiget(
                          name: user['name'],
                          initials: user['initials'],
                          age: user['age'],
                          gender: user['gender'],
                          isSelected: user['isSelected'],
                          onTap: () {
                            final updatedList = List<Map<String, dynamic>>.from(
                              value,
                            );

                            updatedList[index] = {
                              ...updatedList[index],
                              'isSelected': !updatedList[index]['isSelected'],
                            };

                            viewModel.usersShare.value = updatedList;
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              CustomButton(
                onPressed: () {
                  context.pop();
                },
                text: 'SHARE',
              ),
            ],
          ),
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
    return "Select Share Templates Screen";
  }
}
