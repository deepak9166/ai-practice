import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/app_enums.dart';
import 'package:meditrack/presentation/screens/base/base_view_model.dart';
import 'package:meditrack/presentation/screens/base/screen_state.dart';
import 'package:image_picker/image_picker.dart';

class CustomExerciseViewModel extends BaseViewModel {
  final ValueNotifier<bool> isTimeBased = ValueNotifier<bool>(true);
  final ValueNotifier<String> selectedImage = ValueNotifier('');
  final ValueNotifier<String> selectedVideo = ValueNotifier('');

  int selectedExerciseIndex = 0;
  ExerciseDetailLayout viewType = ExerciseDetailLayout.tabbed;

  final List<Map<String, dynamic>> exercises = [
    {
      'title': 'Upper Body Strength',
      'status': 'completed',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Chest, Shoulders, Triceps',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Depending on the variation of the back extension, the following equipment may be used to optimize support.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Lower Body Strength',
      'status': 'pending',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Quads, Glutes, Hamstrings',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Lower body focused workout to improve balance and strength.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Upper Body Strength',
      'status': 'completed',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Chest, Shoulders, Triceps',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Depending on the variation of the back extension, the following equipment may be used to optimize support.',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Lower Body Strength',
      'status': 'pending',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Quads, Glutes, Hamstrings',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Lower body focused workout to improve balance and strength.',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Upper Body Strength',
      'status': 'completed',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Chest, Shoulders, Triceps',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Depending on the variation of the back extension, the following equipment may be used to optimize support.',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Lower Body Strength',
      'status': 'pending',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Quads, Glutes, Hamstrings',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Lower body focused workout to improve balance and strength.',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Upper Body Strength',
      'status': 'completed',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Chest, Shoulders, Triceps',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Depending on the variation of the back extension, the following equipment may be used to optimize support.',
      'htmlDescription': _backExtensionHtml,
    },
    {
      'title': 'Lower Body Strength',
      'status': 'pending',
      'mmgVersion': 'MMG-2.0',
      'muscles': 'Quads, Glutes, Hamstrings',
      'images': [
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
        'assets/img/exercise_dummy.png',
      ],
      'description':
          'Lower body focused workout to improve balance and strength.',
      'htmlDescription': _backExtensionHtml,
    },
  ];

  static const String _backExtensionHtml = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto';
      margin: 0px;
      color: #1f1f1f;
      line-height: 1.6;
    }
    h2 { font-size: 18px; font-weight: 600; margin: 24px 0 12px; }
    p { font-size: 14px; color: #555; margin-bottom: 12px; }
    ul { padding-left: 18px; margin-bottom: 16px; }
    li { margin-bottom: 10px; font-size: 14px; color: #444; }
    li strong { font-weight: 600; color: #222; }
    .note { font-style: italic; color: #666; }
    .table { margin-top: 16px; }
    .row { display: flex; gap: 12px; margin-bottom: 12px; }
    .label { width: 120px; font-weight: 600; font-size: 14px; }
    .value { flex: 1; font-size: 14px; color: #555; }
  </style>
</head>
<body>
  <h2>Equipment Requirements</h2>
  <p>Depending on the variation of the back extension, the following equipment may be used to optimize support, intensity, and form:</p>
  <ul>
    <li><strong>Hyperextension Bench:</strong> The most common & recommended tool for controlled back extensions with proper posture & spine alignment.</li>
    <li><strong>Exercise Mat:</strong> Useful for performing floor-based bodyweight variations if a bench is unavailable.</li>
    <li><strong>Dumbbell or Weight Plate:</strong> For increased resistance during advanced versions, held across the chest or behind the head.</li>
  </ul>
  <p><strong>Condition:</strong></p>
  <p>This exercise is versatile. If you lack access to equipment, it can still be effectively performed using just bodyweight.</p>
  <p class="note">“No equipment needed – bodyweight exercise.”</p>
  <h2>Back Extension</h2>
  <p>The Back Extension is a powerful bodyweight or equipment-assisted movement that targets the lower back. It improves spinal stability, posture, and core strength.</p>
  <h2>Primary & Secondary Muscles Engagement</h2>
  <div class="table">
    <div class="row"><div class="label">Lower Back</div><div class="value">This muscle group stabilizes & extends the spine during the movement.</div></div>
    <div class="row"><div class="label">Glutes</div><div class="value">Activated to support hip extension & maintain posture.</div></div>
    <div class="row"><div class="label">Hamstrings</div><div class="value">Assist in control & hip motion.</div></div>
  </div>
</body>
</html>
""";

  final ValueNotifier<List<Map<String, dynamic>>> equipments = ValueNotifier([
    {'name': 'Treadmill', 'selected': false},
    {'name': 'Dumbbells', 'selected': true},
    {'name': 'Kettlebell', 'selected': true},
    {'name': 'Stationary', 'selected': false},
    {'name': 'Other', 'selected': false},
  ]);

  void toggleSelection(int index) {
    final list = List<Map<String, dynamic>>.from(equipments.value);
    list[index] = {
      ...list[index],
      'selected': !(list[index]['selected'] as bool),
    };
    equipments.value = list;
  }

  List<String> get selectedEquipments => equipments.value
      .where((e) => e['selected'] == true)
      .map((e) => e['name'] as String)
      .toList();

  void deleteExercise(Map<String, dynamic> item) {
    exercises.remove(item);
    notifyListeners();
  }

  Future<void> addExercise() async {
    // Button-level loader
    screenState.value = ScreenState.apiProgress;

    try {
      // await repository.addExercise();

      screenState.value = ScreenState.content;
    } catch (e) {
      screenState.value = ScreenState.error;
    }
  }

  @override
  void dispose() {
    isTimeBased.dispose();
    equipments.dispose();
    selectedImage.dispose();
    super.dispose();
  }
}
