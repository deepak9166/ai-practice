import 'package:flutter/material.dart';
import 'package:meditrack/core/extensions/context_extensions.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

import '../../log/app_logs.dart';
import 'spacing_widgets.dart';

class CustomOTPTextField extends StatefulWidget {
  final String? label;
  final Function(String otpValue) onEntered;
  const CustomOTPTextField({super.key, this.label, required this.onEntered});

  @override
  State<CustomOTPTextField> createState() => _CustomOTPTextFieldState();
}

class _CustomOTPTextFieldState extends State<CustomOTPTextField> {
  ///  Otp pin Controller
  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();

  @override
  Widget build(BuildContext context) {
    final double otpCount = 6;

    bool isLandScap = context.isLandscape;
    final filedWidth = isLandScap
        ? (MediaQuery.sizeOf(context).width / otpCount) - (otpCount * otpCount)
        : (MediaQuery.sizeOf(context).width / otpCount) - 16;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          VerticalSpacing.smallXs,
          Text(
            widget.label ?? "",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryFixedVariant,
              fontSize: 14,
            ),
          ),
          VerticalSpacing.small,
        ],

        Align(
          alignment: Alignment.center,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: 10,
              ),
            ),

            child: SizedBox(
              width: ((filedWidth) * otpCount) + otpCount,
              child: OtpPinField(
                fieldWidth: filedWidth.toDouble(),
                key: _otpPinFieldController,

                ///in case you want to enable autoFill
                autoFillEnable: true,

                ///for Ios it is not needed as the SMS autofill is provided by default, but not for Android, that's where this key is useful.
                textInputAction: TextInputAction.done,

                ///in case you want to change the action of keyboard
                /// to clear the Otp pin Controller
                onSubmit: (text) {
                  appLog('Entered pin is $text');
                  widget.onEntered(text);

                  /// return the entered pin
                },
                onChange: (text) {
                  appLog('Enter on change pin is $text');

                  /// return the entered pin
                },
                onCodeChanged: (code) {
                  appLog('onCodeChanged  is $code');
                },

                /// to decorate your Otp_Pin_Field
                otpPinFieldStyle: OtpPinFieldStyle(
                  activeFieldBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary,
                  defaultFieldBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary,
                  defaultFieldBorderColor: Colors.transparent,
                  activeFieldBorderColor: Colors.transparent,
                  fieldPadding: 1.2,

                  fieldBorderRadius: 0,

                  /// bool to show hints in pin field or not
                  showHintText: true,

                  /// to set the color of hints in pin field or not
                  // hintTextColor: Colors.red,

                  /// To set the text  of hints in pin field
                  // hintText: '1',

                  /// border color for inactive/unfocused Otp_Pin_Field
                  // defaultFieldBorderColor: Colors.red,

                  /// border color for active/focused Otp_Pin_Field
                  // activeFieldBorderColor: Colors.indigo,

                  /// Background Color for inactive/unfocused Otp_Pin_Field
                  // defaultFieldBackgroundColor: Colors.yellow,

                  /// Background Color for active/focused Otp_Pin_Field
                  // activeFieldBackgroundColor: Colors.cyanAccent,

                  /// Background Color for filled field pin box
                  // filledFieldBackgroundColor: Colors.green,

                  /// border Color for filled field pin box
                  // filledFieldBorderColor: Colors.green,
                  //
                  /// gradient border Color for field pin box
                  // activeFieldBorderGradient: LinearGradient(
                  //   colors: [Colors.black, Colors.redAccent],
                  // ),
                  // filledFieldBorderGradient: LinearGradient(
                  //   colors: [Colors.green, Colors.tealAccent],
                  // ),
                  // defaultFieldBorderGradient: LinearGradient(
                  //   colors: [Colors.orange, Colors.brown],
                  // ),
                ),
                maxLength: otpCount.toInt(),

                /// no of pin field
                showCursor: true,

                /// bool to show cursor in pin field or not
                // cursorColor: Colors.indigo,

                /// to choose cursor color

                ///bool which manage to show custom keyboard
                showCustomKeyboard: false,

                /// Widget which help you to show your own custom keyboard in place if default custom keyboard
                // customKeyboard: Container(),
                ///bool which manage to show default OS keyboard
                // showDefaultKeyboard: true,

                /// to select cursor width
                cursorWidth: 2,

                cursorColor: Theme.of(context).colorScheme.primary,

                /// place otp pin field according to yourself
                mainAxisAlignment: MainAxisAlignment.center,

                /// predefine decorate of pinField use  OtpPinFieldDecoration.defaultPinBoxDecoration||OtpPinFieldDecoration.underlinedPinBoxDecoration||OtpPinFieldDecoration.roundedPinBoxDecoration
                ///use OtpPinFieldDecoration.custom  (by using this you can make Otp_Pin_Field according to yourself like you can give fieldBorderRadius,fieldBorderWidth and etc things)
                otpPinFieldDecoration: OtpPinFieldDecoration.custom,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
