
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Header extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path = Path();
    path.lineTo(0, size.height);

    var firstPointStart = Offset(size.width / 5, size.height);  // from point zero to point 1 - distance = 5
    var firstPointEnd = Offset(size.width / 2.25, size.height - 50.0);
    path.quadraticBezierTo(firstPointStart.dx, firstPointStart.dy, firstPointEnd.dx, firstPointEnd.dy);

    var secondPointStart = Offset(size.width + (size.width /3.24), size.height -200);
    var secondPointEnd = Offset(size.width, size.height -10);
    path.quadraticBezierTo(secondPointStart.dx, secondPointStart.dy, secondPointEnd.dx, secondPointEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip( CustomClipper<Path> oldClipper) => false;

}