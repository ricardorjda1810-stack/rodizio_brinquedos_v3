import 'package:flutter/widgets.dart';

class DebugHubItem {
  final String label;
  final String description;
  final WidgetBuilder builder;

  const DebugHubItem({
    required this.label,
    required this.description,
    required this.builder,
  });
}

class DebugHubSection {
  final String title;
  final List<DebugHubItem> items;

  const DebugHubSection({required this.title, required this.items});

  int get itemCount => items.length;
}
