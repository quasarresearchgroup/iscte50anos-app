import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = IscteTheme.iscteColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final Path path1 = Path();
    final Path path2 = Path();
    final Path path3 = Path();
    final Path path4 = Path();

    final double squareSide = size.height * 0.5;
    final double squareInnerSideLength = squareSide * 0.1;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final math.Point<double> leftTopCorner =
        math.Point<double>(centerX - squareSide / 2, centerY - squareSide / 2);
    final math.Point<double> leftBotCorner =
        math.Point<double>(centerX - squareSide / 2, centerY + squareSide / 2);
    final math.Point<double> rightTopCorner =
        math.Point<double>(centerX + squareSide / 2, centerY - squareSide / 2);
    final math.Point<double> rightBotCorner =
        math.Point<double>(centerX + squareSide / 2, centerY + squareSide / 2);

    //left top
    path1.moveTo(
      leftTopCorner.x,
      leftTopCorner.y + squareInnerSideLength,
    );
    path1.lineTo(
      leftTopCorner.x,
      leftTopCorner.y + squareInnerSideLength / 2,
    );
    path1.quadraticBezierTo(
      leftTopCorner.x,
      leftTopCorner.y,
      leftTopCorner.x + squareInnerSideLength / 2,
      leftTopCorner.y,
    );
    path1.lineTo(
      leftTopCorner.x + squareInnerSideLength,
      leftTopCorner.y,
    );

    //right top
    path2.moveTo(
      rightTopCorner.x,
      rightTopCorner.y + squareInnerSideLength,
    );
    path2.lineTo(
      rightTopCorner.x,
      rightTopCorner.y + squareInnerSideLength / 2,
    );
    path2.quadraticBezierTo(
      rightTopCorner.x,
      rightTopCorner.y,
      rightTopCorner.x - squareInnerSideLength / 2,
      rightTopCorner.y,
    );
    path2.lineTo(
      rightTopCorner.x - squareInnerSideLength,
      rightTopCorner.y,
    );

    //left bot
    path3.moveTo(
      leftBotCorner.x,
      leftBotCorner.y - squareInnerSideLength,
    );
    path3.lineTo(
      leftBotCorner.x,
      leftBotCorner.y - squareInnerSideLength / 2,
    );
    path3.quadraticBezierTo(
      leftBotCorner.x,
      leftBotCorner.y,
      leftBotCorner.x + squareInnerSideLength / 2,
      leftBotCorner.y,
    );
    path3.lineTo(
      leftBotCorner.x + squareInnerSideLength,
      leftBotCorner.y,
    );

    //right bot
    path4.moveTo(
      rightBotCorner.x,
      rightBotCorner.y - squareInnerSideLength,
    );
    path4.lineTo(
      rightBotCorner.x,
      rightBotCorner.y - squareInnerSideLength / 2,
    );
    path4.quadraticBezierTo(
      rightBotCorner.x,
      rightBotCorner.y,
      rightBotCorner.x - squareInnerSideLength / 2,
      rightBotCorner.y,
    );
    path4.lineTo(
      rightBotCorner.x - squareInnerSideLength,
      rightBotCorner.y,
    );

    //drawing center for debug
    //canvas.drawCircle(Offset(centerX, centerY), 1, paint);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
