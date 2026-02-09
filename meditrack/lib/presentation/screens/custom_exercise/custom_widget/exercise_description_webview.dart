import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExerciseDescriptionWebView extends StatefulWidget {
  final String htmlContent;
  final double padding;

  const ExerciseDescriptionWebView({
    super.key,
    required this.htmlContent,
    this.padding = 0.0,
  });

  @override
  State<ExerciseDescriptionWebView> createState() =>
      _ExerciseDescriptionWebViewState();
}

class _ExerciseDescriptionWebViewState
    extends State<ExerciseDescriptionWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding),
      child: WebViewWidget(controller: _controller),
    );
  }
}
