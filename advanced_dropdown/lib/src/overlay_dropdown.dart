import 'package:flutter/material.dart';

class OverlayDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onSelected;
  final String title;

  const OverlayDropdown({
    super.key,
    required this.items,
    required this.label,
    required this.onSelected,
    this.title = 'Select item',
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          ...items.map((item) => ListTile(
            title: Text(label(item)),
            onTap: () {
              Navigator.pop(context);
              onSelected(item);
            },
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _open(context),
      child: const Text('Open Dropdown'),
    );
  }
}
