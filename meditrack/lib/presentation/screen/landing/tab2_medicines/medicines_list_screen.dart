import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/extensions/string_extensions.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/data/local/app_database.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/landing/tab2_medicines/medicines_view_model.dart';

import '../../../providers/vm_provider.dart';

class MedicinesListScreen extends ConsumerStatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  ConsumerState<MedicinesListScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState
    extends BaseConsumerState<MedicinesListScreen, MedicinesViewModel>
    with AutomaticKeepAliveClientMixin {
  @override
  void onModelReady(MedicinesViewModel model) {
    super.onModelReady(model);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text("Medicines")),
      body: StreamBuilder<List<Medicine>>(
        stream: viewModel.getAlMedicine(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  asyncSnapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          }
          final data = asyncSnapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No medicines yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add your first medicine to get started',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return _MedicineListCard(medicine: item, onTap: () {
                AppRouter.push(
                  context,
                  AppConstants.routeMedicineDetail,
                  extra: item.id,
                );
              });
            },
          );
        },
      ),
    );
  }

  @override
  MedicinesViewModel createViewModel() {
    return ref.read(medicineVm);
  }

  @override
  String screenName() {
    return "Medicine List";
  }

  @override
  bool get wantKeepAlive => true;
}

class _MedicineListCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;

  const _MedicineListCard({
    required this.medicine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowStock = medicine.lowStockAlert && medicine.totalQuantity < 10;

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        medicine.name.capitalize,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${medicine.totalQuantity} units',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isLowStock) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Low stock',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
