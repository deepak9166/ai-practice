import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/log/app_logs.dart';
import 'package:meditrack/presentation/common_widgets/custom_app_bar.dart';
import 'package:meditrack/presentation/common_widgets/custom_search_bar.dart';
import 'package:meditrack/presentation/screens/templates/common_widget/exercise_list_widget.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final List<Map<String, dynamic>> exercises = [
    {
      'name': 'Push-ups',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': false,
    },
    {
      'name': 'Squats',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': true,
    },
    {
      'name': 'Bench Press',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': true,
      'isFavorite': false,
    },
    {
      'name': 'Deadlift',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': false,
    },
    {
      'name': 'Pull-ups',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': true,
    },
    {
      'name': 'Lunges',
      'type': 'Strength',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': false,
    },
    {
      'name': 'Planks',
      'type': 'Core',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': false,
    },
    {
      'name': 'Burpees',
      'type': 'Cardio',
      'image': PngImageId.chest.path,
      'isSelected': false,
      'isFavorite': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final favoriteExercises = exercises
        .where((e) => e['isFavorite'] == true)
        .toList();
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Exercise List',
        backIcon: Icon(Icons.close_rounded),
        defaultActionTitle: 'SUBMIT',
        onDefaultActionPressed: () {
          appLog('SUBMIT tapped');
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBarView(hintText: 'Search Exercise', onPressed: () {}),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  children: [
                    _buildSection(title: 'Favorites', exercises: exercises),
                    _buildSection(title: 'All Exercises', exercises: exercises),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Map<String, dynamic>> exercises,
  }) {
    if (exercises.isEmpty) return const SizedBox();

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      children: exercises.map((exercise) {
        return ExerciseListWidget(
          exerciseName: exercise['name'],
          exerciseType: exercise['type'],
          isSelected: exercise['isSelected'],
          isFavorite: exercise['isFavorite'],
          exerciseImage: exercise['image'],
          onTap: () {
            setState(() {
              exercise['isSelected'] = !exercise['isSelected'];
            });
          },
          onFavoriteTap: () {
            setState(() {
              exercise['isFavorite'] = !exercise['isFavorite'];
            });
          },
        );
      }).toList(),
    );
  }
}
