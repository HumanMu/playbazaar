import 'package:flutter/material.dart';

class GameListBox extends StatefulWidget {
  final String title;
  final String navigationParameter;
  final Function(String, String)? onTap;

  const GameListBox({
    super.key,
    required this.title,
    required this.navigationParameter,
    this.onTap,
  });

  @override
  GameListBoxState createState() => GameListBoxState();
}

class GameListBoxState extends State<GameListBox> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        setState(() {
          isClicked = !isClicked; // Toggle the clicked state for visual feedback
        });
        if (widget.onTap != null) {
          widget.onTap!(widget.navigationParameter, widget.title); // Call the callback with the navigation parameter
        }
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.red[600],
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:  Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
