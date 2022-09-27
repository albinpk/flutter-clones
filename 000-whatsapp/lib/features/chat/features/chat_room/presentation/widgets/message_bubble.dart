import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/models.dart';
import '../../../../../../core/utils/extensions/platform_type.dart';
import '../../../../../../core/utils/themes/custom_colors.dart';
import '../../../../chat.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    this.showArrow = false,
  }) : super(key: key);

  final Message message;

  /// Whether to show an arrow in message bubble
  /// that pointing to message author.
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final customColors = CustomColors.of(context);
    const padding = 8.0; // Padding for the message text
    final isMobile = theme.platform.isMobile;
    final messageTextStyle = textTheme.bodyMedium!.copyWith(
      fontSize: isMobile ? 16 : null,
    );
    final timeTextStyle = textTheme.bodySmall!.copyWith(
      fontSize: isMobile ? null : 10,
    );

    final isUserMessage = message.author == context.watch<User>();
    final messageText = message.content.text;
    final timeText = message.time.toString().substring(0, 7);

    // Adding extra white spaces at the end of text to
    // wrap the line before overlapping the time text.
    // And the unicode character at the end is for prevent text trimming.

    // Calculate timeText width
    // eg: width of "1:11" and "12:44" is different or
    // width of "4:44" and "1:11" is different in non-monospace fonts
    final timeTextWidth = textWidth(timeText, timeTextStyle);
    final messageTextWidth = textWidth(messageText, messageTextStyle);
    final whiteSpaceWidth = textWidth(' ', messageTextStyle);
    // More space on desktop (+8)
    final extraSpaceCount =
        ((timeTextWidth / whiteSpaceWidth).round()) + (isMobile ? 2 : 8);
    final extraSpace = '${' ' * extraSpaceCount}\u202f';
    final extraSpaceWidth = textWidth(extraSpace, messageTextStyle);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1.2),
      child: CustomPaint(
        painter: _MessageBubblePainter(
          color: isUserMessage
              ? customColors.sendMessageBubbleBackground!
              : customColors.receiveMessageBubbleBackground!,
          bubbleArrow: showArrow
              ? isUserMessage
                  ? _MessageBubbleArrow.right
                  : _MessageBubbleArrow.left
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constrains) {
            final maxWidth = constrains.maxWidth - (padding * 2);

            // Deciding the placement of time text.

            //                                      maxWidth
            //                                         |
            // Short message                           v
            // |---------------|
            // | MESSAGE  time |
            // |---------------|

            // text + extraSpace < maxWidth
            // |---------------------------------------|
            // | MESSAGE.MESSAGE.MESSAGE.MESSAGE  time |
            // |---------------------------------------|

            // text < maxWidth
            // |---------------------------------------|
            // | MESSAGE.MESSAGE.MSGS..MESSAGE.MESSAGE |
            // |                                  time |
            // |---------------------------------------|

            // text > maxWidth
            // |---------------------------------------|
            // | MESSAGE.MESSAGE.MSGS..MESSAGE.MESSAGE |
            // | MESSAGE.MESSAGE.MESSAGE          time |
            // |---------------------------------------|
            final isTimeInSameLine =
                messageTextWidth + extraSpaceWidth < maxWidth ||
                    messageTextWidth > maxWidth;

            // Using Stack to show message time in bottom right corner.
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(padding).copyWith(
                    bottom: isTimeInSameLine ? padding : 25,
                  ),

                  // Message text
                  child: Text(
                    '$messageText'
                    '${isTimeInSameLine ? extraSpace : ''}',
                    style: messageTextStyle,
                  ),
                ),

                // Message time
                Positioned(
                  bottom: 5,
                  right: 10,
                  child: Text(
                    timeText,
                    style: timeTextStyle,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Returns the width of given `text` using TextPainter
  double textWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}

enum _MessageBubbleArrow { left, right }

class _MessageBubblePainter extends CustomPainter {
  const _MessageBubblePainter({
    this.bubbleArrow,
    required this.color,
  });

  /// Message bubble arrow side.
  ///
  /// For the first message in a section of messages by same user.
  final _MessageBubbleArrow? bubbleArrow;

  /// Background color for message bubble.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const bubbleCurve = 15.0;
    const arrowSize = 11.0;
    const arrowCurve = 6.0;

    final paint = Paint()..color = color;
    final path = Path();

    // Top part of message bubble
    switch (bubbleArrow) {
      case _MessageBubbleArrow.left:
        path
          ..moveTo(0, arrowSize)
          ..lineTo((0 - arrowSize) + arrowCurve, arrowCurve)
          // Arrow to left
          ..conicTo(0 - arrowSize, 0, (0 - arrowSize) + arrowCurve, 0, 0.5)
          ..lineTo(w - bubbleCurve, 0)
          ..quadraticBezierTo(w, 0, w, bubbleCurve); // Top right curve
        break;
      case _MessageBubbleArrow.right:
        path
          ..moveTo(0, bubbleCurve)
          ..quadraticBezierTo(0, 0, bubbleCurve, 0) // Top left curve
          ..lineTo((w + arrowSize) - arrowCurve, 0)
          // Arrow to right
          ..conicTo(
              w + arrowSize, 0, (w + arrowSize) - arrowCurve, arrowCurve, 0.5)
          ..lineTo(w, arrowSize);
        break;
      case null:
        path
          ..moveTo(0, bubbleCurve)
          ..quadraticBezierTo(0, 0, bubbleCurve, 0) // Top left curve
          ..lineTo(w - bubbleCurve, 0)
          ..quadraticBezierTo(w, 0, w, bubbleCurve); // Top right curve
        break;
    }

    // Bottom part of message bubble
    path
      ..lineTo(w, h - bubbleCurve)
      ..quadraticBezierTo(w, h, w - bubbleCurve, h) // Bottom right curve
      ..lineTo(bubbleCurve, h)
      ..quadraticBezierTo(0, h, 0, h - bubbleCurve); // Bottom left curve

    canvas.drawShadow(
      path.shift(const Offset(0, -0.5)),
      Colors.black,
      1,
      true,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
