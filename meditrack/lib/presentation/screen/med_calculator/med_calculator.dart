import 'package:flutter/material.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../common_widgets/custom_input_field.dart';
import '../../screens/calender/workout_summary_screen.dart';

class MedCalculator extends StatefulWidget {
  final Function(String totalMedicne) onDone;
  const MedCalculator({super.key, required this.onDone});

  @override
  State<MedCalculator> createState() => _MedCalculatorState();
}

class _MedCalculatorState extends State<MedCalculator> {
  TextEditingController totalTab = TextEditingController();
  TextEditingController medicineQtyPerTab = TextEditingController();
  TextEditingController tabPrice = TextEditingController();
  TextEditingController signleMedicinePrice = TextEditingController();
  double totalAmoutValue = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Calulator',style: TextTheme.of(context).titleMedium,),
              VerticalSpacing.medium,
              CustomInputField(
                hint: "Total Tabs",
                controller: totalTab,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateValues();
                },
              ),
              VerticalSpacing.medium,
              CustomInputField(
                hint: "Tap Price",
                controller: tabPrice,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateValues();
                },
              ),

              VerticalSpacing.medium,
              CustomInputField(
                hint: "Medician Qty/Tab",
                controller: medicineQtyPerTab,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateValues();
                },
              ),
              VerticalSpacing.medium,
              CustomInputField(
                hint: "One Medicine Price",
                controller: signleMedicinePrice,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _calculateValues();
                },
              ),
              VerticalSpacing.medium,
            ],
          ),
        ),
        _msgMusclesWorkTable(),
        VerticalSpacing.medium,
        Text("Total Medicine Qty : ${_totalMedicineQty()}"),
        Divider(height: 0),
        Text(
          "Total Ammount : ${_totalAmount()}",
          style: TextTheme.of(context).titleMedium,
        ),
        
        Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButton(onPressed: () {
            widget.onDone(_totalMedicineQty());
            AppRouter.pop(context);
          }, text: "Done"),
        )
      ],
    );
  }

  Widget _msgMusclesWorkTable() {
    return CustomTableComponant(
      highlightColumn: -1,

      columnFlex: [1, 1],
      heading: 'Med',
      headerRowValue: ["T Tabs", "T P", "Med Q", "A Med"],
      rowValue: [
        [
          totalTab.text,
          tabPrice.text,
          medicineQtyPerTab.text,
          priceSingleMedicine(),
        ],
      ],
    );
  }

  _calculateValues() {
    setState(() {});
  }

  String priceSingleMedicine() {
    //  pricePerTab.text =  (double.parse(totalPatti.text)/).toString();
    if (medicineQtyPerTab.text.trim().isNotEmpty &&
        tabPrice.text.trim().isNotEmpty) {
      var tabPriceValue = double.tryParse(tabPrice.text) ?? 0.0;
      var medQty = double.tryParse(medicineQtyPerTab.text) ?? 0.0;

      var sMedValue = tabPriceValue / medQty;
      signleMedicinePrice.text = "${sMedValue.toStringAsFixed(2)}";
      return signleMedicinePrice.text;
    } else if (totalAmoutValue > 0) {
      // var singleMedcalue = totalAmoutValue/
      return "M";
    } else {
      return signleMedicinePrice.text;
    }
  }

  String _totalAmount() {
    var tabCount = double.tryParse(totalTab.text) ?? 0.0;

    var tabPriceValue = double.tryParse(this.tabPrice.text) ?? 0.0;

    totalAmoutValue = tabCount * tabPriceValue;

    return totalAmoutValue.toString();
  }

  String medicineQtyPerTabCal() {
    return medicineQtyPerTab.text;
  }

  String _totalMedicineQty() {
    var tabCount = double.tryParse(totalTab.text) ?? 0.0;

    var medQty = double.tryParse(medicineQtyPerTab.text) ?? 0.0;

    var totalMeds = tabCount * medQty;

    return totalMeds.toStringAsFixed(0);
  }
}
