import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/settings_controller/settings_controller.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingsController settingsController = Get.find<SettingsController>();
  var isSignedIn = false.obs;


  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings".tr,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("btn_sounds".tr),
                  Obx(() => Switch(
                    value: settingsController.isButtonSoundsEnabled.value,
                    onChanged: (value) {
                      settingsController.toggleButtonSounds();
                    },
                  )),
                ],
              )
            ],
          ),
        ),
    ),
    );
  }
}
