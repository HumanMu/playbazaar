import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameListBox extends StatefulWidget {
  final String title;
  final String quizPath;

  const  GameListBox({
    super.key,
    required this.title,
    required this.quizPath,
  });

  @override
  GameListBoxState createState() => GameListBoxState();
}

class GameListBoxState extends State<GameListBox> {
  bool hasDifficulities = false;
  bool showOptions = false;

  // Define a list of quiz paths that should have difficulty options
  static final List<String> difficultiesQuizPaths = [
    'hazaragi_af',
  ];

  @override
  void initState() {
    super.initState();
    showOptions = difficultiesQuizPaths.contains(widget.quizPath);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //if (widget.onTap != null) {
          if (showOptions) {
            setState(() {
              hasDifficulities = !hasDifficulities;
            });
          } else {
            _handleNavigation();
          }
        //}
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.red[600],
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          hasDifficulities ? _buildDifficultySection() : Container(),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _difficultyLevels.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => _handleNavigationWithOption(option),
                child: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleNavigation() {
    Get.toNamed(
      '/optionizedPlayScreen',
      arguments: {
        'selectedPath': widget.quizPath,
        'quizTitle': widget.title,
      },
    );
  }

  void _handleNavigationWithOption(String selectedOption) {
    final isWithOptions = selectedOption == 'with_options'.tr;

    Get.toNamed(
      isWithOptions ? '/optionizedPlayScreen' : '/noneOptionizedPlayScreen',
      arguments: {
        'selectedPath': widget.quizPath,
        'quizTitle': widget.title,
      },
    );
  }

  final List<String> _difficultyLevels = [
    'with_options'.tr,
    'without_options'.tr,
  ];
}