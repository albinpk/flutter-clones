import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/models.dart';
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
    final isUserMessage = message.author == context.watch<User>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 2),
      child: CustomPaint(
        painter: _MessageBubblePainter(
          color: isUserMessage ? Colors.green : Colors.grey,
          bubbleArrow: showArrow
              ? isUserMessage
                  ? _MessageBubbleArrow.right
                  : _MessageBubbleArrow.left
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message.content.text),
        ),
      ),
    );
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
    const curve = 10.0; // Bubble curve
    const arrowCurve = 5.0;

    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, curve);

    // Top part of message bubble
    switch (bubbleArrow) {
      case _MessageBubbleArrow.left:
        path
          ..lineTo((0 - curve) + arrowCurve, arrowCurve)
          // Arrow to left
          ..conicTo(0 - curve, 0, (0 - curve) + arrowCurve, 0, 0.5)
          ..lineTo(w - curve, 0)
          ..quadraticBezierTo(w, 0, w, curve); // Top right curve
        break;
      case _MessageBubbleArrow.right:
        path
          ..quadraticBezierTo(0, 0, curve, 0) // Top left curve
          ..lineTo((w + curve) - arrowCurve, 0)
          // Arrow to right
          ..conicTo(w + curve, 0, (w + curve) - arrowCurve, arrowCurve, 0.5)
          ..lineTo(w, curve);
        break;
      case null:
        path
          ..quadraticBezierTo(0, 0, curve, 0) // Top left curve
          ..lineTo(w - curve, 0)
          ..quadraticBezierTo(w, 0, w, curve); // Top right curve
        break;
    }

    // Bottom part of message bubble
    path
      ..lineTo(w, h - curve)
      ..quadraticBezierTo(w, h, w - curve, h) // Bottom right curve
      ..lineTo(curve, h)
      ..quadraticBezierTo(0, h, 0, h - curve); // Bottom left curve

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
