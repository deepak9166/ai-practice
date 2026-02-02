import 'package:flutter/material.dart';

class NotchedShapeBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const double notchSize = 10.0;
    const double notchPosition = 15.0; // Distance from right edge
    Path path = Path();
    path.moveTo(rect.left, rect.top + notchSize);
    path.lineTo(rect.right - notchPosition - notchSize, rect.top + notchSize);
    path.lineTo(rect.right - notchPosition, rect.top);
    path.lineTo(rect.right - notchPosition + notchSize, rect.top + notchSize);
    path.lineTo(rect.right, rect.top + notchSize);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final Path path = getOuterPath(rect);
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) => this;
}

class CustomTemplatePopupMenu extends StatelessWidget {
  final Function(String) onSelected;
  final List<Map<String, String>> options;
  final bool showOnTap;
  final Widget? child;

  const CustomTemplatePopupMenu({
    super.key,
    required this.onSelected,
    required this.options,
    this.showOnTap = false,
    this.child,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Map<String, String>> options,
    required Function(String) onSelected,
    Offset? position,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position != null
            ? Rect.fromLTWH(position.dx, position.dy, 40, 40)
            : const Rect.fromLTWH(200, 200, 40, 40),
        Offset.zero & overlay.size,
      ),
      shape: NotchedShapeBorder(),
      color: Colors.white,
      items: options
          .map(
            (option) => PopupMenuItem<String>(
              value: option['value'],
              child: Text(
                option['text'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selected != null) {
      onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showOnTap) {
      return GestureDetector(
        onTapDown: (details) {
          show(
            context,
            options: options,
            onSelected: onSelected,
            position: details.globalPosition,
          );
        },
        child: child ?? const SizedBox.shrink(),
      );
    }

    // Default: icon button
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      offset: const Offset(0, 40),
      shape: NotchedShapeBorder(),
      color: Colors.white,
      onSelected: onSelected,
      itemBuilder: _buildItems,
    );
  }

  List<PopupMenuEntry<String>> _buildItems(BuildContext context) {
    return options.map((option) {
      return PopupMenuItem<String>(
        value: option['value'],
        child: Text(
          option['text']!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      );
    }).toList();
  }
}
