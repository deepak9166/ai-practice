import 'package:flutter/material.dart';
import 'package:meditrack/core/theme/app_theme.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

import '../../../../config/svg_config.dart';
import '../../../common_widgets/smart_image_view.dart';

class ExerciseInfoCard extends StatelessWidget {
  const ExerciseInfoCard({
    super.key,
    required this.title,
    this.templateType,
    this.strengthBadge,
    this.mmg,
    this.msg,
  });

  final String title;
  final String? templateType;
  final String? strengthBadge;
  final String? mmg;
  final String? msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              if (strengthBadge != null) HorizontalSpacing(),
              if (strengthBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFF9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    strengthBadge!,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryThemeColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 30),

          ..._buildInfoRows(),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows() {
    final List<Widget> rows = [];
    if (templateType != null) {
      rows.add(
        _InfoRow(
          svgPath: SvgImageId.templatesType.path,
          title: 'Template Type',
          value: templateType!,
        ),
      );
      rows.add(const SizedBox(height: 24));
    }
    if (mmg != null) {
      rows.add(
        _InfoRow(svgPath: SvgImageId.strength.path, title: 'MMG', value: mmg!),
      );
      rows.add(const SizedBox(height: 24));
    }
    if (msg != null) {
      rows.add(
        _InfoRow(svgPath: SvgImageId.strength.path, title: 'MSG', value: msg!),
      );
    }
    return rows;
  }
}

class _InfoRow extends StatelessWidget {
  final String svgPath;
  final String title;
  final String value;

  const _InfoRow({
    required this.svgPath,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: SmartImageView(svgPath, width: 22, height: 22),
        ),
        const HorizontalSpacing(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
