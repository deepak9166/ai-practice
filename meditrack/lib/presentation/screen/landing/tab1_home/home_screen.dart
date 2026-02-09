import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common_model/exercise_model.dart';
import '../../../common_widgets/app_drawer.dart';
import '../../../common_widgets/medicine_card.dart';
import '../../../common_widgets/spacing_widgets.dart';
import '../../../providers/vm_provider.dart';
import '../../base/base_consumer_state.dart';
import 'home_view_model.dart';
import 'upcoming_exercise_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseConsumerState<HomeScreen, HomeViewModel>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Home',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: ListView(
        children: [
          VerticalSpacing.mediumExtra,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Today’s Medicines',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          VerticalSpacing.small,
          StreamBuilder<List<MedicineModel>>(
            stream: viewModel.todayMedicinesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Center(
                    child: snapshot.hasError
                        ? Text(
                            'Error loading',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                  ),
                );
              }
              final list = snapshot.data!;
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'No medicines scheduled for today.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                );
              }
              return Column(
                children: list
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MedicineCard(
                          item: item,
                          cardType: MedicineCardType.medium,
                          onAction: () {
                            if (item.intakeId == null) return;
                            _showMarkAsTakenDialog(context, item);
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          VerticalSpacing.mediumExtra,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Upcoming Medicines',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          VerticalSpacing.small,
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: UpcomingMedicineList(
              stream: viewModel.upcomingMedicinesStream,
            ),
          ),
          VerticalSpacing.mediumExtra,
        ],
      ),
    );
  }

  void _showMarkAsTakenDialog(BuildContext context, MedicineModel item) {
    final theme = Theme.of(context);
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 20),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Mark as taken',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you take this medicine?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              child: Text(
                item.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Yes, taken'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && item.intakeId != null) {
        viewModel.markIntakeAsTaken(item.intakeId!);
      }
    });
  }

  @override
  HomeViewModel createViewModel() {
    return ref.read(homeVm);
  }

  @override
  String screenName() {
    return 'Home';
  }

  @override
  bool get wantKeepAlive => true;
}
