import 'package:flutter/material.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/common_widgets/rich_text_title.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../core/constants/app_constants.dart';
import '../../common_model/dropdown_value_model.dart';
import '../../common_widgets/custom_input_dropdown.dart';
import '../../common_widgets/custom_input_field.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello")),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: ListView(
          children: [
            const RichTextTitle(
              description:
                  'Get started by creating your account & embark on a seamless app experience',
              title1: 'Profile',
              title2: '\nCompletion',
            ),
            VerticalSpacing(),
            CustomInputField(
              controller: TextEditingController(),
              label: 'First Name',
              hint: 'Enter your first name',
              keyboardType: TextInputType.name,
              tooltip:
                  'Optional information; providing your full name would help your gym buddies (friends, instructors, trainees) identify you',
            ),
            VerticalSpacing(),
            CustomInputField(
              controller: TextEditingController(),
              label: 'Last Name',
              hint: 'Enter your last name',
              keyboardType: TextInputType.name,
              tooltip:
                  'Optional information; providing your full name would help your gym buddies (friends, instructors, trainees) identify you',
            ),
            VerticalSpacing(),
            CustomInputField(
              controller: TextEditingController(),
              label: 'date of birth',
              hint: 'dd-mm-yyyy',
              keyboardType: TextInputType.name,
              tooltip:
                  'Optional information; providing your full name would help your gym buddies (friends, instructors, trainees) identify you',
            ),
            VerticalSpacing(),
            CustomInputField(
              controller: TextEditingController(),
              label: 'Age',
              hint: 'i.e 21',
              keyboardType: TextInputType.number,
              enabled: false,
              tooltip: '',
            ),
            VerticalSpacing(),
            CustomDropdownInput(
              items: [
                DropdownValueModel(title: 'Male', value: 'male'),
                DropdownValueModel(title: 'Female', value: 'female'),
              ],

              label: 'Gender',
              hint: 'Select gender',
              tooltip: ' in development', // TODO:
              onChanged: (value) {},
              value: null,
            ),
            VerticalSpacing(),

            CustomDropdownInput(
              items: [
                DropdownValueModel(title: 'India', value: 'india'),
                DropdownValueModel(title: 'US', value: 'us'),
                DropdownValueModel(title: 'Australia', value: 'australia'),
              ],

              label: 'Country',
              hint: 'Select country',
              tooltip: ' in development', // TODO:
              onChanged: (value) {},
              value: null,
            ),
            VerticalSpacing(),
            CustomInputField(
              controller: TextEditingController(),
              label: 'Zip Code',
              hint: 'Enter zip code',
              keyboardType: TextInputType.number,
              tooltip: ' in development', // TODO:
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                AppRouter.push(context, AppConstants.routeSelectPreferenceUnit);
              },
              child: Text('SUBMIT'),
            ),
          ),
        ),
      ),
    );
  }
}
