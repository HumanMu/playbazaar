import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class GameListBox extends StatefulWidget {
  final String title;
  final String gamePath;
  final Color baseColor;

  const GameListBox({
    super.key,
    required this.title,
    required this.gamePath,
    this.baseColor = const Color(0xFFE53935),
  });

  @override
  StyledGameTileState createState() => StyledGameTileState();
}

class StyledGameTileState extends State<GameListBox> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool showOptions = false;
  bool isExpanded = false;

  // Use const for better performance
  static const List<String> optionsPaths = [
    'hazaragi_af',
    'geography_fa',
    'general_nowledge_fa'
  ];

  // Cache screen size
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    showOptions = optionsPaths.contains(widget.gamePath);
    //print("Game path: ${widget.gamePath}");

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

  // Calculate responsive dimensions
  double _getResponsiveHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // Adjust tile height based on screen size
    return height < 600 ? 60 : height < 900 ? 70 : 80;
  }

  double _getResponsiveFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Adjust font size based on screen width
    return width < 360 ? 16 : width < 600 ? 18 : 20;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: width < 360 ? 12 : width < 600 ? 20 : 24,
      vertical: width < 360 ? 2 : 4,
    );
  }

  void _handleNavigation() {
    final queryData = Uri(queryParameters: {
      'selectedPath': widget.gamePath,
      'quizTitle': widget.title,
    }).query;
    context.push('/optionizedPlayScreen?$queryData');
  }

  void _handleNavigationWithOption(String selectedOption) {
    final isWithOptions = selectedOption == 'with_options'.tr;
    final path = isWithOptions ? '/optionizedPlayScreen' : '/noneOptionizedPlayScreen';

    final queryData = Uri(queryParameters: {
      'selectedPath': widget.gamePath,
      'quizTitle': widget.title,
    }).query;
    context.push('$path?$queryData');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Container(
              margin: _getResponsivePadding(context),
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * 0.95, // Prevent overflow on small screens
                minHeight: _getResponsiveHeight(context),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.baseColor,
                    Colors.green.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(screenWidth < 360 ? 10 : 15),
                boxShadow: [
                  BoxShadow(
                    color: widget.baseColor.withValues(alpha: 0.4),
                    blurRadius: screenWidth < 360 ? 6 : 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(screenWidth < 360 ? 10 : 15),
                  onTap: () {
                    if (showOptions) {
                      setState(() {
                        isExpanded = !isExpanded;
                        isExpanded
                            ? _animationController.forward()
                            : _animationController.reverse();
                      });
                    } else {
                      _handleNavigation();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title.tr,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis, // Prevent text overflow
                            maxLines: 2, // Allow up to 2 lines for longer titles
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: screenWidth < 360 ? 20 : 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showOptions)
              SizeTransition(
                sizeFactor: _animation,
                child: isExpanded ? _buildOptionsSection(context) : null,
              ),
          ],
        );
      },
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        screenHeight * 0.01,
        screenWidth * 0.05,
        screenHeight * 0.02,
      ),
      child: Wrap( // Use Wrap instead of Row for better responsiveness
        alignment: WrapAlignment.spaceEvenly,
        spacing: screenWidth * 0.02,
        runSpacing: screenHeight * 0.01,
        children: [
          _buildOptionButton('with_options'.tr, context),
          _buildOptionButton('without_options'.tr, context),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.4,
        minWidth: screenWidth * 0.3,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth < 360 ? 8 : 10),
          ),
          elevation: screenWidth < 360 ? 2 : 3,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: screenHeight * 0.01,
          ),
        ),
        onPressed: () => _handleNavigationWithOption(option),
        child: Text(
          option,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: _getResponsiveFontSize(context) * 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
