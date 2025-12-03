import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:playbazaar/core/dialog/dialog_listner.dart';
import '../controller/online_ludo_controller.dart';


class CustomSideMenu extends ConsumerStatefulWidget {
  const CustomSideMenu({super.key});

  @override
  ConsumerState<CustomSideMenu> createState() => _CustomSideMenuState();
}



class _CustomSideMenuState extends ConsumerState<CustomSideMenu> {
  bool _isDrawerOpen = false;
  static const double _collapsedWidth = 60.0;
  static const double _expandedWidth = 0.35;
  final controller = Get.find<OnlineLudoController>();


  @override
  Widget build(BuildContext context) {
    final river = ref.watch(dialogManagerProvider.notifier);

    double screenWidth = MediaQuery.of(context).size.width;
    double currentWidth = _isDrawerOpen
        ? screenWidth * _expandedWidth
        : _collapsedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
      width: currentWidth,
      decoration: BoxDecoration(
        color: _isDrawerOpen? Colors.green : Colors.transparent,
        borderRadius: _isDrawerOpen? BorderRadiusDirectional.only(
          topEnd: const Radius.circular(20),
          bottomEnd: const Radius.circular(20),

        ) : BorderRadius.zero,
      ),

      child: Column(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            },
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all<Color>(
                Colors.white,
              ),
              backgroundColor: WidgetStateProperty.all<Color>(
                Colors.red, //_isDrawerOpen ? Colors.green : Colors.red,
              ),
            ),
            icon:  Icon(
                _isDrawerOpen? Icons.close : Icons.menu
            ),
          ),

          if (_isDrawerOpen)
            Column(
              children: [
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _isDrawerOpen = !_isDrawerOpen;
                    });
                    await controller.showGameOverDialog();
                    river.closeAllDialogs();
                  },
                  child: Text("leave_game".tr, style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  )),
                ),
                Obx(() => controller.isHost.value
                  ? TextButton(
                    onPressed: () => controller.showWaitingRoom(isManaging: true),
                    child: Text("kick_a_member".tr, style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    )),
                  ) : Container(),
                ),
              ],
            ),
        ],
      ),

    );
  }
}