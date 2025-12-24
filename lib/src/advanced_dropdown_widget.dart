import 'package:flutter/material.dart';

typedef DropdownItemBuilder<T> = Widget Function(
    BuildContext context,
    T item,
    bool isSelected,
    );

class AdvancedDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? initialValue;
  final String hint;
  final ValueChanged<T?> onChanged;

  /// UI customization
  final BorderRadius borderRadius;
  final Color fieldColor;
  final Color dropdownColor;
  final List<BoxShadow> boxShadow;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  /// Custom item builder
  final DropdownItemBuilder<T>? itemBuilder;

  const AdvancedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hint = 'Select item',
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
    this.textStyle,
    this.hintStyle,
    this.itemBuilder,
  });

  @override
  State<AdvancedDropdown<T>> createState() => _AdvancedDropdownState<T>();
}

class _AdvancedDropdownState<T> extends State<AdvancedDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  T? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  void _toggleDropdown() {
    if (_overlay == null) {
      _overlay = _createOverlay();
      Overlay.of(context).insert(_overlay!);
    } else {
      _closeDropdown();
    }
  }

  void _closeDropdown() {
    _overlay?.remove();
    _overlay = null;
  }

  OverlayEntry _createOverlay() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown, // ✅ outside tap closes dropdown
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, size.height + 6),
                showWhenUnlinked: false,
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
                        final isSelected = item == selected;
                        return InkWell(
                          onTap: () {
                            setState(() => selected = item);
                            widget.onChanged(item);
                            _closeDropdown();
                          },
                          child: widget.itemBuilder != null
                              ? widget.itemBuilder!(
                            context,
                            item,
                            isSelected,
                          )
                              : Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              item.toString(),
                              style: widget.textStyle,
                            ),
                          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: widget.fieldColor,
            borderRadius: widget.borderRadius,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selected != null ? selected.toString() : widget.hint,
                style: selected != null
                    ? widget.textStyle
                    : widget.hintStyle ??
                    const TextStyle(color: Colors.grey),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }
}
