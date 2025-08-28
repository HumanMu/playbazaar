import 'package:flutter/material.dart';


const textInputDecoration =  InputDecoration(
    
  hintTextDirection: TextDirection.rtl,
  labelStyle: TextStyle(
    color: Colors.grey,
  ),
  filled: true,
  // fillColor: Colors.amber,
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      width: 2,
      color: Colors.red,
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(width: 2, color: Colors.limeAccent),
  ),
);

Widget profileButton (BuildContext context, buttonText, landingPage) {
  return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),),
        backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.redAccent;
          } else {
            return Colors.black;
          }
        }),),
        
      onPressed: () {
        Navigator.push( context,
          MaterialPageRoute(builder: (context) => landingPage));
      },
      child: Text(buttonText),
      
    );
}


void navigateToAnotherScreen(BuildContext context, newPage) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => newPage));
}

void navigateAndReplaceScreen(BuildContext context, newPage) {
  Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => newPage));
}

Future<void> replaceCurrentWidget(BuildContext context, VoidCallback onSuccess) async {
  await Future.delayed(const Duration(seconds: 2));
  onSuccess.call();
}

