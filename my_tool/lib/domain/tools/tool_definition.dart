import 'package:flutter/material.dart';

/// Immutable description of a tool that can be surfaced in the shell UI.
class ToolDefinition {
  const ToolDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
}

