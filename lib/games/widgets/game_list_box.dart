import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameListBox extends StatefulWidget {
  final String title;
  final String quizPath;
  final Color baseColor;

  const GameListBox({
    super.key,
    required this.title,
    required this.quizPath,
    this.baseColor = const Color(0xFFE53935), // Modern blue as default
  });

  @override
  GameListBoxState createState() => GameListBoxState();
}

class GameListBoxState extends State<GameListBox> with SingleTickerProviderStateMixin {
  bool hasDifficulities = false;
  bool showOptions = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static final List<String> difficultiesQuizPaths = [
    'hazaragi_af',
    'geography_fa',
    'general_nowledge_fa'
  ];

  @override
  void initState() {
    super.initState();
    showOptions = difficultiesQuizPaths.contains(widget.quizPath);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (showOptions) {
          setState(() {
            hasDifficulities = !hasDifficulities;
            hasDifficulities
              ? _animationController.forward()
              : _animationController.reverse();
          });
        } else {
          _handleNavigation();
        }
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.baseColor,
                  Colors.green.shade300 //widget.baseColor.withValues(alpha:0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: widget.baseColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  if (showOptions) {
                    setState(() {
                      hasDifficulities = !hasDifficulities;
                      hasDifficulities
                          ? _animationController.forward()
                          : _animationController.reverse();
                    });
                  } else {
                    _handleNavigation();
                  }
                },
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: hasDifficulities ? _buildDifficultySection() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _difficultyLevels.map((option) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                onPressed: () => _handleNavigationWithOption(option),
                child: Text(
                  option,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
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