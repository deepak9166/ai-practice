import 'profile_qna_model.dart';

final List<ProfileQnaModel> profileQnaList = [

  /// STEP 1 – Overall Workout Frequency
  ProfileQnaModel(
    step: 1,
    totalSteps: 10,
    title: 'How often would you like to workout per week?',
    description:
    '(across all types of workout – strength, cardio, classes, playing sports…)',
    type: QnaType.singleChoice,
    info: "Select # of Times Per Week",
    options: [
      QnaOptionModel(id: '1', title: '1 to 3', value: '1-3'),
      QnaOptionModel(id: '2', title: '2 to 4', value: '2-4'),
      QnaOptionModel(id: '3', title: '3 to 5', value: '3-5'),
      QnaOptionModel(id: '4', title: '4 to 6', value: '4-6'),
      QnaOptionModel(id: '5', title: '6+', value: '6+'),
    ],
  ),

  /// STEP 2 – Strength Frequency
  ProfileQnaModel(
    step: 2,
    totalSteps: 10,
    title: 'How often would you like to do Strength Workouts per week?',
    description:
    '(aka strength/resistance training involving weights, machines, or body-weight exercises)',
    type: QnaType.singleChoice,
    info: "Select # of Times Per Week",
    options: [
      QnaOptionModel(id: '0', title: 'None', value: 'none'),
      QnaOptionModel(id: '1', title: '1 to 3', value: '1-3'),
      QnaOptionModel(id: '2', title: '2 to 4', value: '2-4'),
      QnaOptionModel(id: '3', title: '3 to 5', value: '3-5'),
      QnaOptionModel(id: '4', title: '4 to 6', value: '4-6'),
      QnaOptionModel(id: '5', title: '6+', value: '6+'),
    ],
  ),

  /// STEP 3 – Cardio Frequency
  ProfileQnaModel(
    step: 3,
    totalSteps: 10,
    title: 'How often would you like to do Cardio Workouts per week?',
    description:
    '(such as running, swimming, cycling, rowing, or cardio-focused classes)',
    type: QnaType.singleChoice,
    info: "Select # of Times Per Week",
    options: [
      QnaOptionModel(id: '0', title: 'None', value: 'none'),
      QnaOptionModel(id: '1', title: '1 to 3', value: '1-3'),
      QnaOptionModel(id: '2', title: '2 to 4', value: '2-4'),
      QnaOptionModel(id: '3', title: '3 to 5', value: '3-5'),
      QnaOptionModel(id: '4', title: '4 to 6', value: '4-6'),
      QnaOptionModel(id: '5', title: '6+', value: '6+'),
    ],
  ),

  /// STEP 4 – Target Body Weight
  ProfileQnaModel(
    step: 4,
    totalSteps: 10,
    title: 'What is your target Body Weight within next 6 months?',
    type: QnaType.input,
    hintText: 'Enter Weight',
    unit: 'kg',
  ),

  /// STEP 5 – Target Body Fat %
  ProfileQnaModel(
    step: 5,
    totalSteps: 10,
    title: 'What is your target Body Fat % within next 6 months?',
    type: QnaType.input,
    hintText: 'Enter Body Fat (%)',
    unit: '%',
  ),

  /// STEP 6 – Target Waist Size
  ProfileQnaModel(
    step: 6,
    totalSteps: 10,
    title: 'What is your target Waist Size within next 6 months?',
    type: QnaType.input,
    hintText: 'Enter Waist Size',
    unit: 'cm',
  ),

  /// STEP 7 – Strength Experience
  ProfileQnaModel(
    step: 7,
    totalSteps: 10,
    title: 'How many years have you been doing Strength Workouts?',
    description: '(either continuously or overall)',
    type: QnaType.singleChoice,
    options: [
      QnaOptionModel(id: '1', title: '< 1 year', value: '<1'),
      QnaOptionModel(id: '2', title: '1 to 2 years', value: '1-2'),
      QnaOptionModel(id: '3', title: '2 to 4 years', value: '2-4'),
      QnaOptionModel(id: '4', title: '4 to 6 years', value: '4-6'),
      QnaOptionModel(id: '5', title: '6+ years', value: '6+'),
    ],
  ),

  /// STEP 8 – Primary Objectives (Percentage Allocation)
  ProfileQnaModel(
    step: 8,
    totalSteps: 10,
    title: 'What are your primary objectives for working out?',
    description:
    '(Total allocation must be 100%, each value must be ≥ 10%)',
    type: QnaType.percentage,
    info: "% allocation to each option; total needs to be 100%; input value for each option to be ≥10%",
    options: [
      QnaOptionModel(
        id: '1',
        title: 'Gain More Muscle Mass & Strength',
        value: 0,
      ),
      QnaOptionModel(
        id: '2',
        title: 'Maintain Current Muscle Mass & Strength',
        value: 0,
      ),
      QnaOptionModel(
        id: '3',
        title: 'Improve Cardiovascular Endurance',
        value: 0,
      ),
      QnaOptionModel(
        id: '4',
        title: 'Lose Fat & Get in Better Shape Overall',
        value: 0,
      ),
      QnaOptionModel(
        id: '5',
        title: 'Improve Targeted Muscle Shape or Mobility',
        value: 0,
      ),
    ],
  ),

  /// STEP 9 – Recent Progress Feeling
  ProfileQnaModel(
    step: 9,
    totalSteps: 10,
    title: 'How do you feel about your recent fitness progress?',
    description: '(relative to your goals; in the past 6–12 months)',
    type: QnaType.singleChoice,
    options: [
      QnaOptionModel(
        id: '1',
        title: 'I am very satisfied; have been improving meaningfully',
        value: 'very_satisfied',
      ),
      QnaOptionModel(
        id: '2',
        title: 'I am somewhat satisfied, but could improve further',
        value: 'somewhat_satisfied',
      ),
      QnaOptionModel(
        id: '3',
        title: 'I hit a plateau; no visible progress',
        value: 'plateau',
      ),
      QnaOptionModel(
        id: '4',
        title: 'Diminishing returns; need diagnosis & course-correct',
        value: 'diminishing',
      ),
      QnaOptionModel(
        id: '5',
        title: 'It’s not working; need diagnosis & significant changes',
        value: 'not_working',
      ),
    ],
  ),

  /// STEP 10 – Personalized Insights Consent
  ProfileQnaModel(
    step: 10,
    totalSteps: 10,
    title:
    'Would you like to receive personalized insights based on your goals vs progress?',
    description:
    '(Once a quarter, our fitness expert team reviews your progress. Completely private & free for long-term users.)',
    type: QnaType.singleChoice,
    options: [
      QnaOptionModel(
        id: '1',
        title: 'No – I am good with the App Analytics',
        value: 'no',
      ),
      QnaOptionModel(
        id: '2',
        title: 'Yes – Send summary via App Message Inbox',
        value: 'inbox',
      ),
      QnaOptionModel(
        id: '3',
        title: 'Yes – Set up a private 1-1 call',
        value: 'call',
      ),
      QnaOptionModel(
        id: '4',
        title: 'Yes – both the above two options',
        value: 'both',
      ),
    ],
  ),
];
