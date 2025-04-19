import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/constants/app_colors.dart';
import '../../../global_widgets/dialog/accept_dialog.dart';


class LudoHomeScreen extends StatefulWidget {
  const LudoHomeScreen({super.key});
  @override
  State<LudoHomeScreen> createState() => _LudoHomeScreenState();
}

class _LudoHomeScreenState extends State<LudoHomeScreen> {
  GlobalKey keyBar = GlobalKey();
  bool enabledRobots = false;
  bool teamPlay = false;


  // Ludo colors
  //final Color redColor = const Color(0xFFE53935);
  final Color greenColor = const Color(0xFF43A047);
  final Color yellowColor = const Color(0xFFFFB300);
  final Color blueColor = const Color(0xFF1E88E5);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color accentColor = const Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        key: keyBar,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ludo_missions'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: body(),
      )
    );
  }

  Widget body() {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxWidth: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Game logo or icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  _buildQuadrant(Alignment.topLeft, AppColors.primary),
                  _buildQuadrant(Alignment.topRight, greenColor),
                  _buildQuadrant(Alignment.bottomLeft, yellowColor),
                  _buildQuadrant(Alignment.bottomRight, blueColor),
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Center(
                        child: GestureDetector(  // Using GestureDetector instead of TextButton
                          onTap: () => acceptDialog(
                              context,
                              'ludo_home_screen_guide_title'.tr,
                              'ludo_home_screen_guide'.tr
                          ),
                          child: Text(
                            'guide'.tr,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,  // Smaller font size
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text('choose_player_numbers'.tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: CupertinoCheckbox(
                        value: enabledRobots,
                        onChanged: (val) {
                          setState(() {
                            enabledRobots = val!;
                          });
                        },
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "enable_robots".tr,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.5,
                      child: CupertinoCheckbox(
                        value: teamPlay,
                        onChanged: (val) {
                          setState(() {
                            teamPlay = val!;
                          });
                        },
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "play_in_team".tr,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Player selection grid
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    gameTypeContainer(2, AppColors.primary),
                    gameTypeContainer(3, greenColor),
                    gameTypeContainer(4, blueColor),
                    gameTypeContainer(1, yellowColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable quadrant widget
  Widget _buildQuadrant(Alignment alignment, Color color) {
    double? top = alignment.y < 0 ? 0 : null;
    double? bottom = alignment.y > 0 ? 0 : null;
    double? left = alignment.x < 0 ? 0 : null;
    double? right = alignment.x > 0 ? 0 : null;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 60,
        height: 60,
        color: color,
      ),
    );
  }

  Widget gameTypeContainer(int numberPlayers, Color color) {

    return GestureDetector(
      onTap: () => Get.toNamed('/ludoPlayScreen',
        arguments: {
          'numberOfPlayer' : numberPlayers,
          'teamPlay': teamPlay,
          'enabledRobots': enabledRobots,
        }),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                numberPlayers == 1 ? Icons.computer : Icons.people,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            numberPlayers !=1
                ? Text("$numberPlayers ${'players'.tr}",
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
            : Text("computer".tr,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}