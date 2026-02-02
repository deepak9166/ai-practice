import 'package:flutter/material.dart';
import 'package:meditrack/presentation/screens/landing/tab_excercise/filter/filter_view_model.dart';

import '../../../../common_widgets/custom_button.dart';
import '../../../../common_widgets/spacing_widgets.dart';

class TemplateTypeFilter extends StatefulWidget {
  final String heading;
  final List<FilterValus> templateTypeList;
  const TemplateTypeFilter({
    super.key,
    required this.heading,
    required this.templateTypeList,
  });

  @override
  State<TemplateTypeFilter> createState() => _TemplateTypeFilterState();
}

class _TemplateTypeFilterState extends State<TemplateTypeFilter> {
  List<int> selectedIds = [];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(17.5),
            child: Text(
              widget.heading,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Divider(height: 0),
          Expanded(
            child: ListView.separated(
              itemCount: widget.templateTypeList.length,
              itemBuilder: (context, index) {
                var item = widget.templateTypeList[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  onTap: () {
                    setState(() {
                      if (selectedIds.contains(item.id)) {
                        selectedIds.remove(item.id);
                      } else {
                        selectedIds.add(item.id);
                      }
                    });
                  },
                  title: Text(item.labelName),
                  trailing: IgnorePointer(
                    child: Radio(
                      value: true,
                      groupValue: selectedIds.contains(item.id),
                      onChanged: (value) {},
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(indent: 20,endIndent: 20, height: 0,),
            ),
          ),
           SafeArea(
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton(
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: Colors.black,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //       side: BorderSide(color: Colors.black, width: 1),
                    //     ),

                    //     onPressed: () {},
                    //     child: Center(child: Text('CLEAR')),
                    //   ),
                    // ),

                      Expanded(
                        
                      child: CustomButton(
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.black,
                        onPressed: () {}, text: 'CLEAR'),
                    ),
                    HorizontalSpacing.medium,
                    Expanded(
                      child: CustomButton(onPressed: () {}, text: 'APPLY'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
