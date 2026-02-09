import 'package:flutter/material.dart';

class StatusLabelWidget extends StatelessWidget {
  final String status;

  const StatusLabelWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color? color;
    String statusText = "";

    switch (status) {
      case "completed":
        color = const Color(0xff28B446);
        statusText = "Completed";
        break;
      case "approved":
        color = const Color(0xff28B446);
        statusText = "Approved";
        break;
      case "pending":
        color = const Color(0xffFBBB00);
        statusText = "Pending";
        break;
      case "notlog":
        color = const Color(0xffF14336);
        statusText = "Time not logged";
        break;
      default:
        color = Colors.red;
        statusText = "Unknown";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.2),
      ),
      child: Text(
        statusText,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontSize: 10, color: color),
      ),
    );
  }
}
