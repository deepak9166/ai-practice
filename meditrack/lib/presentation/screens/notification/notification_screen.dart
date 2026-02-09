import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification'), elevation: 1),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            title: Text(
              'John Doe just decline your proposal that you shared.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            subtitle: Text(
              '21 Feb, 2023 at 10:12am',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
        itemCount: 20,
        separatorBuilder: (context, index) =>
            Divider(height: 0, indent: 0, endIndent: 0),
      ),
    );
  }
}
