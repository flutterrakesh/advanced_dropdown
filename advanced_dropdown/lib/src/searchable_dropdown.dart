import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final String hint;

  final BorderRadius borderRadius;
  final Color dropdownColor;
  final List<BoxShadow> boxShadow;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint = 'Search & select',
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
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
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();

  OverlayEntry? _overlay;
  List<T> filtered = [];
  T? selected;

  void _openDropdown() {
    if (_overlay != null) return;
    _overlay = _createOverlay();
    Overlay.of(context).insert(_overlay!);
  }

  void _closeDropdown() {
    _overlay?.remove();
    _overlay = null;
  }

  void _filter(String query) {
    filtered = widget.items
        .where((e) => widget
        .itemLabel(e)
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();

    if (filtered.isNotEmpty) {
      _openDropdown();
    } else {
      _closeDropdown();
    }

    _overlay?.markNeedsBuild();
  }

  OverlayEntry _createOverlay() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    return OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown, // ✅ tap outside closes dropdown
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, size.height + 8),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: size.width,
                    margin: EdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: widget.dropdownColor,
                      borderRadius: widget.borderRadius,
                      boxShadow: widget.boxShadow,
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: filtered.map((item) {
                        return InkWell(
                          onTap: () {
                            selected = item;
                            _controller.text =
                                widget.itemLabel(item);
                            widget.onChanged(item);
                            _closeDropdown();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              widget.itemLabel(item),
                              softWrap: true,
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
  void dispose() {
    _controller.dispose();
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        onTap: () {
          if (_controller.text.isNotEmpty) {
            _filter(_controller.text);
          }
        },
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: widget.borderRadius,
          ),
        ),
        onChanged: (value) {
          _filter(value); // 🔥 auto open here
        },
      ),
    );
  }
}
