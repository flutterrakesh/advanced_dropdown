import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<List<T>> onChanged;

  final BorderRadius borderRadius;
  final Color fieldColor;
  final Color dropdownColor;
  final List<BoxShadow> boxShadow;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.label,
    required this.onChanged,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fieldColor = Colors.white,
    this.dropdownColor = Colors.white,
    this.boxShadow = const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      )
    ],
  });

  @override
  State<MultiSelectDropdown<T>> createState() =>
      _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  final List<T> selectedItems = [];

  void _openDropdown() {
    if (_overlay != null) return;
    _overlay = _createOverlay();
    Overlay.of(context).insert(_overlay!);
  }

  void _closeDropdown() {
    _overlay?.remove();
    _overlay = null;
  }

  void _toggleDropdown() {
    _overlay == null ? _openDropdown() : _closeDropdown();
  }

  OverlayEntry _createOverlay() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown, // 👈 outside tap close
        child: Stack(
          children: [
            Positioned(
              width: 200,
              child: CompositedTransformFollower(
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.topCenter,
                link: _layerLink,
                offset: Offset(0, size.height + 6),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.dropdownColor,
                      borderRadius: widget.borderRadius,
                      boxShadow: widget.boxShadow,
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: widget.items.map((item) {
                        final isSelected = selectedItems.contains(item);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(widget.label(item)),
                          controlAffinity:
                          ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() {
                              val == true
                                  ? selectedItems.add(item)
                                  : selectedItems.remove(item);
                            });

                            widget.onChanged(List.from(selectedItems));

                            // 🔥 instant overlay repaint
                            _overlay?.markNeedsBuild();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.fieldColor,
            borderRadius: widget.borderRadius,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedItems.isEmpty
                ? const [
              Text(
                'Select items',
                style: TextStyle(color: Colors.grey),
              )
            ]
                : selectedItems.map((item) {
              return Chip(
                label: Text(widget.label(item)),
                onDeleted: () {
                  setState(() => selectedItems.remove(item));
                  widget.onChanged(List.from(selectedItems));
                  _overlay?.markNeedsBuild(); // 🔥 sync
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
