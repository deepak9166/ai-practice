import 'package:flutter/material.dart';
import 'package:meditrack/core/extensions/date_extensions.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/extension/keyboard_hide_extesion.dart';
import 'package:meditrack/extension/toast_helper.dart';
import 'package:meditrack/presentation/common_widgets/custom_button.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_field.dart';

import '../../../common_widgets/spacing_widgets.dart';
import 'medicines_view_model.dart';

class AddExpenseBottomSheet extends StatefulWidget {
  final MedicinesDetailViewModel viewModel;
  final Expense? expense;
  final VoidCallback onSaved;

  const AddExpenseBottomSheet({
    super.key,
    required this.viewModel,
    this.expense,
    required this.onSaved,
  });

  @override
  State<AddExpenseBottomSheet> createState() => _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends State<AddExpenseBottomSheet> {
  late final TextEditingController _qtyController;
  late final TextEditingController _pricePaidController;
  late final TextEditingController _pricePerUnitController;
  late DateTime _purchaseDate;
  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _qtyController = TextEditingController(text: e?.quantityBought.toString() ?? '');
    _pricePaidController = TextEditingController(text: e?.pricePaid.toString() ?? '');
    _pricePerUnitController = TextEditingController(text: e?.pricePerUnit.toString() ?? '');
    _purchaseDate = e?.purchaseDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _pricePaidController.dispose();
    _pricePerUnitController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyController.text.trim());
    final pricePaid = double.tryParse(_pricePaidController.text.trim());
    final pricePerUnit = double.tryParse(_pricePerUnitController.text.trim());

    if (qty == null || qty < 1) {
      context.showWarning('Enter valid quantity');
      return;
    }
    if (pricePaid == null || pricePaid < 0) {
      context.showWarning('Enter valid price paid');
      return;
    }
    if (pricePerUnit == null || pricePerUnit < 0) {
      context.showWarning('Enter valid price per unit');
      return;
    }

    if (_isEdit) {
      await widget.viewModel.updateExpense(
        expenseId: widget.expense!.id,
        quantityBought: qty,
        pricePaid: pricePaid,
        pricePerUnit: pricePerUnit,
        purchaseDate: _purchaseDate,
      );
      context.showSuccess('Expense updated');
    } else {
      await widget.viewModel.addExpense(
        quantityBought: qty,
        pricePaid: pricePaid,
        pricePerUnit: pricePerUnit,
        purchaseDate: _purchaseDate,
      );
      context.showSuccess('Expense added');
    }
    if (!mounted) return;
    context.hideKeyboard();
    Navigator.of(context).pop();
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEdit ? 'Edit expense' : 'Add expense',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              VerticalSpacing.medium,
              CustomInputField(
                hint: 'Quantity bought',
                controller: _qtyController,
                keyboardType: TextInputType.number,
              ),
              VerticalSpacing.small,
              CustomInputField(
                hint: 'Price paid',
                controller: _pricePaidController,
                keyboardType: TextInputType.number,
              ),
              VerticalSpacing.small,
              CustomInputField(
                hint: 'Price per unit',
                controller: _pricePerUnitController,
                keyboardType: TextInputType.number,
              ),
              VerticalSpacing.small,
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Purchase date'),
                subtitle: Text(_purchaseDate.toDDMMMYYYY()),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              VerticalSpacing.medium,
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      borderColor: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        context.hideKeyboard();
                        Navigator.of(context).pop();
                      },
                      text: 'Cancel',
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: CustomButton(
                      onPressed: _submit,
                      text: _isEdit ? 'Update' : 'Add',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
