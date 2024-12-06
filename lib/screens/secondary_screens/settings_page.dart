import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/settings_controller/notification_settings_controller.dart';
import 'package:playbazaar/screens/widgets/settings_switch.dart';

import '../../languages/custom_language.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  final NotificationSettingsController settingsController = Get.find<NotificationSettingsController>();
  var isSignedIn = false.obs;
  int selectedCategoryIndex = 0;

  final List<SettingsCategory> categories = [
    SettingsCategory(
      title: 'sounds',
      icon: Icons.volume_up,
    ),
    SettingsCategory(
      title: 'notifications',
      icon: Icons.notifications,
    ),
    SettingsCategory(
      title: 'account',
      icon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings".tr,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? Colors.red : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            categories[index].icon,
                            color: isSelected ? Colors.red : Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text(
                            categories[index].title.tr,
                            style: TextStyle(
                              color: isSelected ? Colors.red : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: _buildSettingsContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    switch (selectedCategoryIndex) {
      case 0: // Sounds
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textTitle('sounds'.tr),
            Obx(() => SettingsSwitch(
              title: "btn_sounds".tr,
              value: settingsController.isButtonSoundsEnabled.value,
              onToggle: settingsController.toggleButtonSounds,
            )),
          ],
        );
      case 1: // Notifications
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textTitle('notifications'.tr),
            Obx(() => SettingsSwitch(
              title: "friend_request".tr,
              value: settingsController.isFriendRequestNotificationEnabled.value,
              onToggle: settingsController.toggleFriendRequestNotifications,
            )),
            SizedBox(height: 10),
            Obx(() => SettingsSwitch(
              title: "friends_messages".tr,
              value: settingsController.isMessageNotificationEnabled.value,
              onToggle: settingsController.toggleMessageNotifications,
            )),
            SizedBox(height: 20),
            Divider(height: 1),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(onPressed: settingsController.saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),
                child: Text("btn_save".tr),
              ),
            )
          ],
        );
      case 2: // Account
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textTitle('choose_language'.tr),
            Container(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  CustomLanguage().languageDialog(context);
                },
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('language'.tr,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  Widget textTitle(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    );
  }
}

class SettingsCategory {
  final String title;
  final IconData icon;

  SettingsCategory({
    required this.title,
    required this.icon,
  });
}