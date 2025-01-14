import 'package:flutter/material.dart';

class LaughingEmoji extends StatefulWidget {
  const LaughingEmoji({super.key});

  @override
  LaughingEmojiState createState() => LaughingEmojiState();
}

class LaughingEmojiState extends State<LaughingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Eyes
          Positioned(
            left: 20,
            top: 30,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 30,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Animated Mouth
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                bottom: 20 + (20 * _animation.value), // Move mouth up and down
                child: Transform.rotate(
                  angle: -0.5 * _animation.value, // Rotate mouth for a laughing effect
                  child: Container(
                    width: 40,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(50), right: Radius.circular(50)),
                    ),
                  ),
                ),
              );
            },
          ),
          // Tears (or laughter lines)
          Positioned(
            left: 10,
            bottom: 40,
            child: Transform.rotate(
              angle: -0.7,
              child: Container(
                width: 20,
                height: 5,
                color: Colors.blue,
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 40,
            child: Transform.rotate(
              angle: 0.7,
              child: Container(
                width: 20,
                height: 5,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}