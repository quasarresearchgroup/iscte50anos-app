import 'package:flutter/material.dart';

class InvertedTClipper extends CustomClipper<Path> {
  InvertedTClipper({required this.width});
  final double width;
  @override
  Path getClip(Size size) {
    final path = Path();
    //top line
    path.moveTo(size.width / 2 - width / 2, 0.0);
    path.lineTo(size.width / 2 + width / 2, 0.0);

    path.lineTo(size.width / 2 + width / 2, size.height / 2 - width / 2);

    path.lineTo(size.width, size.height / 2 - width / 2);
    path.lineTo(size.width, size.height / 2 + width / 2);

    path.lineTo(size.width / 2 - width / 2, size.height / 2 + width / 2);
    path.lineTo(size.width / 2 - width / 2, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(InvertedTClipper oldClipper) => false;
}
