import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import 'smart_image_view.dart';
import 'spacing_widgets.dart';

class CustomInputPhoneNumberField extends StatelessWidget {
  const CustomInputPhoneNumberField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          VerticalSpacing.smallXs,
          Text(
            label ?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
              fontSize: 14,
            ),
          ),
          VerticalSpacing.small,
        ],
        SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.circular(8),
                    color: Color.fromRGBO(208, 201, 234, 0.3),
                  ),
                  child: CountryCodePicker(
                    onChanged: (countryCode) {
                      // setState(() {
                      //   _selectedCountryCode = countryCode.dialCode ?? '+1';
                      // });
                    },
                    initialSelection: 'US',
                    favorite: ['+1', '+91', '+44'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: TextStyle(fontSize: 16),
                    builder: (countryCode) {
                      // appLog("countryCode?.flagUri ${countryCode?.flagUri}");
                      return Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            HorizontalSpacing.smallXs,
                            if (countryCode?.flagUri != null)
                              SmartImageView(
                                countryCode?.flagUri ?? "",
                                packageName: 'country_code_picker',
                                width: 30,
                                height: 30,
                                radius: 15,
                              ),
                            HorizontalSpacing.smallXs,
                            if (countryCode?.dialCode != null)
                              FittedBox(
                                child: Text(
                                  countryCode?.dialCode ?? '-',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                            HorizontalSpacing.smallXs,
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              HorizontalSpacing.small,
              Expanded(
                flex: 5,
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  enabled: enabled,
                  maxLines: maxLines,

                  decoration: InputDecoration(hintText: hint),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
