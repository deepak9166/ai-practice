import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/providers/vm_provider.dart';

class RemainingMedicineCounts extends ConsumerStatefulWidget {
  final int medicineId;
  const RemainingMedicineCounts({super.key, required this.medicineId});

  @override
  ConsumerState<RemainingMedicineCounts> createState() =>
      _RemainingMedicineCountsState();
}

class _RemainingMedicineCountsState extends ConsumerState<RemainingMedicineCounts>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(medicineDetailVm(widget.medicineId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<int>(
      stream: viewModel.remainingCountStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? viewModel.medicineDetail?.totalQuantity ?? 0;
        final hasData = snapshot.connectionState == ConnectionState.active ||
            snapshot.hasData;

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: hasData ? _pulseAnimation.value : 1.0,
              child: child,
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.surface,
                      ]
                    : [
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                        theme.colorScheme.surface,
                      ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Remaining',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          '$count',
                          key: ValueKey<int>(count),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'units left',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
