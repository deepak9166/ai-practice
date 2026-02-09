import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import 'filter_view_model.dart';

class MmgFilter extends StatefulWidget {
  final String heading;
  final List<FilterItemsModel> mmgList;
  const MmgFilter({super.key, required this.heading, required this.mmgList});

  @override
  State<MmgFilter> createState() => _MmgFilterState();
}

class _MmgFilterState extends State<MmgFilter> {
  List<int> selectedItem = [];
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
            child: ListView.builder(
              itemCount: widget.mmgList.length,
              itemBuilder: (listContext, index) {
                var item = widget.mmgList[index];

                if (item.name.isEmpty) {
                  return Column(
                    children: [VerticalSpacing.medium, gridViewWidget(item)],
                  );
                } else {
                  return ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 20),
                    initiallyExpanded: true,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    children: [gridViewWidget(item)],
                  );
                }
              },
            ),
          ),
          SafeArea(
            child: SizedBox(
              height: 54,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.black,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: 'CLEAR',
                      ),
                    ),
                    HorizontalSpacing.medium,
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pop(context, selectedItem);
                        },
                        text: 'APPLY',
                      ),
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

  Widget gridViewWidget(FilterItemsModel item) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      itemCount: item.filterValues.length,
      physics: NeverScrollableScrollPhysics(),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 137,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (gridContext, index) {
        var itemValue = item.filterValues[index];
        bool isSelected = selectedItem.contains(itemValue.id);
        return cardItem(itemValue, isSelected);
      },
    );
  }

  Widget cardItem(FilterValus item, bool isSelected) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          if (selectedItem.contains(item.id)) {
            selectedItem.remove(item.id);
          } else {
            selectedItem.add(item.id);
          }
        });
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).primaryColor),
              )
            : BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(8),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SmartImageView(PngImageId.yoga.path, radius: 50, height: 62),
            SizedBox(height: 6),
            Text(
              item.labelName,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
