import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/custom_input_dropdown.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:super_tooltip/super_tooltip.dart';

import '../../config/svg_config.dart';

class TooltipWidget extends StatefulWidget {
  final String message;
  final bool fixDirectLeft;
  const TooltipWidget({
    super.key,
    required this.message,
    this.fixDirectLeft = false,
  });

  @override
  State<TooltipWidget> createState() => _TooltipWidgetState();
}

class _TooltipWidgetState extends State<TooltipWidget> {
  late SuperTooltipController _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = SuperTooltipController();
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
    
      touchThroughAreaShape: ClipAreaShape.rectangle,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.55, // 50% screen
        ),
        child: Text(
          widget.message,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
     
      popupDirectionBuilder: widget.fixDirectLeft
          ? null
          : () => autoTooltipDirection(context),
      backgroundColor: const Color(0xff333333),
      barrierColor: Colors.transparent,
      elevation: 0,
      
      arrowBaseWidth: 16,
      arrowLength: 8,
      arrowTipDistance: 10,
      shadowColor: Colors.transparent,
      controller: _tooltipController,
      borderRadius: 6,

  
      // constraints: const BoxConstraints(minHeight: 0),

      child: SmartImageView(SvgImageId.info.path),
    );
  }

  TooltipDirection autoTooltipDirection(BuildContext context) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  final Offset position = box.localToGlobal(Offset.zero);
  final Size size = box.size;
  final Size screenSize = MediaQuery.of(context).size;

  const double tooltipHeight = 80; // approx tooltip height

  var width = MediaQuery.sizeOf(context).width;

// If small label with small message will be show right → show right
  if (position.dx  < width / 2 && widget.message.length < 50) {
    return TooltipDirection.right;
  }

  // If not enough space below → show up
  if (position.dy + size.height + tooltipHeight > screenSize.height) {
    return TooltipDirection.up;
  }

  // If not enough space above → show down
  if (position.dy < tooltipHeight) {
    return TooltipDirection.down;
  }

  return TooltipDirection.down;
}

}
