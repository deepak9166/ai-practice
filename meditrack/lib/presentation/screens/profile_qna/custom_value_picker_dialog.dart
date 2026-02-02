import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

class CustomValuePickerDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<int> mainValues, // e.g. 40–140
    required List<int> decimalValues, // e.g. 0–99 or 0–9
    required List<String> units, // e.g. ['kg', 'lb'] OR ['%']
    required int initialMainValue,
    int initialDecimalValue = 0,
    int initialUnitIndex = 0,
    required ValueChanged<String> onSave,
    bool showDecimal = true,
  }) async {
    int selectedMain = initialMainValue;
    int selectedDecimal = initialDecimalValue;
    int selectedUnitIndex = initialUnitIndex;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryFixedVariant,
                            ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final value = showDecimal
                              ? '$selectedMain.${selectedDecimal.toString().padLeft(2, '0')} ${units[selectedUnitIndex]}'
                              : '$selectedMain ${units[selectedUnitIndex]}';
                          onSave(value);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SAVE',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryFixed,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  VerticalSpacing(size: 12),

                  /// PICKERS
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// SINGLE CONTINUOUS SELECTION ROW
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        /// PICKERS
                        Row(
                          children: [
                            /// MAIN VALUE
                            Expanded(
                              flex: showDecimal ? 3 : 4,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                selectionOverlay: null,
                                // ✅ IMPORTANT
                                scrollController: FixedExtentScrollController(
                                  initialItem: mainValues.indexOf(
                                    initialMainValue,
                                  ),
                                ),
                                onSelectedItemChanged: (index) {
                                  selectedMain = mainValues[index];
                                },
                                children: mainValues
                                    .map(
                                      (v) => Center(
                                        child: Text(
                                          v.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                            if (showDecimal) ...[
                              /// DECIMAL
                              Expanded(
                                flex: 2,
                                child: CupertinoPicker(
                                  itemExtent: 40,
                                  selectionOverlay: null,
                                  // ✅ IMPORTANT
                                  scrollController: FixedExtentScrollController(
                                    initialItem: initialDecimalValue,
                                  ),
                                  onSelectedItemChanged: (index) {
                                    selectedDecimal = decimalValues[index];
                                  },
                                  children: decimalValues
                                      .map(
                                        (v) => Center(
                                          child: Text(
                                            v.toString().padLeft(2, '0'),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSecondary,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],

                            /// UNIT
                            Expanded(
                              flex: showDecimal ? 2 : 3,
                              child: CupertinoPicker(
                                itemExtent: 40,
                                selectionOverlay: null,
                                // ✅ IMPORTANT
                                scrollController: FixedExtentScrollController(
                                  initialItem: initialUnitIndex,
                                ),
                                onSelectedItemChanged: (index) {
                                  selectedUnitIndex = index;
                                },
                                children: units
                                    .map(
                                      (u) => Center(
                                        child: Text(
                                          u,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSecondary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
