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

  Future<void> _onTextChanged(String value) async {
    if (value.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    final results = await widget.fetchSuggestions(value);

    if (!mounted) return;

    setState(() {
      _suggestions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (value) {
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
