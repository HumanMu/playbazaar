import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late bool hasDifficulities = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          bool hasLevel = checkForDifficulities(widget.navigationParameter);
          if(hasLevel){
            setState(() {
              hasDifficulities = !hasDifficulities;
            });
          }
          else{
            widget.onTap!(widget.navigationParameter, widget.title); // Call the callback with the navigation parameter
          }
        }
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
                  color:  Colors.white,
                ),
              ),
            ),
          ),
          hasDifficulities? buildDifficultySection(widget.navigationParameter) : Container(),
        ]
      ),
    );
  }

  Widget buildDifficultySection(String quizPath) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: difficultyLevels.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent
                  ),
                  onPressed: () => handleDifficultySelection(quizPath, option),
                  child: Text(option,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
    );
  }



  void handleDifficultySelection(String quizPath, String options) {
    Get.toNamed(
        '/quizPlayPlage',
        arguments: {
          'selectedPath': quizPath,
          'quizTitle': widget.title,
          'withOption': options == 'with_options'.tr? true : false,
        }
    );
    //Navigator.pushNamed(context, quizPath, arguments: difficulty);
  }

  bool checkForDifficulities(String pathParameter) {
    switch(pathParameter){
      case "hazaragi_af":
        return true;
      default:
        return false;
    }
  }


  final List<String> difficultyLevels = [
    'with_options'.tr,
    'without_options'.tr,
  ];
}
