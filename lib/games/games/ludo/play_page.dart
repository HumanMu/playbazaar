
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/constants.dart';
import '../../widgets/game_list_box.dart';

class LudoWorldWar extends StatefulWidget {
  const LudoWorldWar({super.key});

  @override
  State<LudoWorldWar> createState() => _LudoWorldWarState();
}

class _LudoWorldWarState extends State<LudoWorldWar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("games_list".tr,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: Center(
        child: _dictionaryList(),
      ),
    );
  }


  Widget _dictionaryList() {
    return ListView.builder(
        itemCount: ludoTypes.length,
        itemBuilder: (context, index){
          return GameListBox(
            title: ludoTypes[index],
            navigationParameter: ludoTypes[index],
            onTap: _handleNavigation,
          );
        }
    );
  }

  _handleNavigation(String? selectedPath) {
    print("Navigation Parameter: $selectedPath");
  }

}

