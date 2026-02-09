import 'dart:async';

import 'package:flutter/material.dart';

class CustomTextfieldAutofill extends StatefulWidget {
  final Future<List<String>> Function(String query) fetchSuggestions;
  final ValueChanged<String> onItemSelected;
  final TextEditingController controller;
  final String hintText;

  const CustomTextfieldAutofill({
    super.key,
    required this.fetchSuggestions,
    required this.controller,
    required this.onItemSelected,
    this.hintText = '',
  });

  @override
  State<CustomTextfieldAutofill> createState() =>
      _CustomTextfieldAutofillState();
}

class _CustomTextfieldAutofillState extends State<CustomTextfieldAutofill> {
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;
  String _lastQuery = '';

  static const _debounceDuration = Duration(milliseconds: 300);

  void _onTextChanged(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    _debounce?.cancel();
    setState(() => _isLoading = true);

    _debounce = Timer(_debounceDuration, () async {
      _lastQuery = query;
      final results = await widget.fetchSuggestions(query);

      if (!mounted) return;
      if (_lastQuery != query) return;

      setState(() {
        _isLoading = false;
        _suggestions = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        final text = textEditingValue.text;
        if (text.isEmpty) return const Iterable<String>.empty();
        return _suggestions;
      },
      onSelected: widget.onItemSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }
}
