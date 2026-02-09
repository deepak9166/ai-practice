import 'package:flutter/material.dart';

class SearchOverlayField extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String> onItemSelected;

  const SearchOverlayField({
    super.key,
    required this.suggestions,
    required this.onItemSelected,
  });

  @override
  State<SearchOverlayField> createState() => _SearchOverlayFieldState();
}

class _SearchOverlayFieldState extends State<SearchOverlayField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      }
    });
  }

  void _onTextChanged(String value) {
    _filteredSuggestions = widget.suggestions
        .where(
          (item) => item.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();

    if (value.isNotEmpty && _filteredSuggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final item = _filteredSuggestions[index];
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    _controller.text = item;
                    widget.onItemSelected(item);
                    _removeOverlay();
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _removeOverlay();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
