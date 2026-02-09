import 'package:flutter/material.dart';
import 'package:meditrack/core/constants/color_helper.dart';
import 'package:meditrack/core/theme/app_theme.dart';

class ShareTemplatesWiget extends StatelessWidget {
  final String name;
  final String initials;
  final String gender;
  final String age;
  final bool isSelected;
  final VoidCallback onTap;

  const ShareTemplatesWiget({
    super.key,
    required this.name,
    required this.initials,
    required this.gender,
    required this.age,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: RandromColor.randomAvatarColor(),
              child: Text(
                initials,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF0D47A1),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // IF badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightThemeColro.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'IF',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepPurple,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$age Years • $gender',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            isSelected
                ? const Icon(Icons.check_circle, color: Colors.deepPurple)
                : Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
