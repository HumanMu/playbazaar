import 'package:flutter/material.dart';

class UzbekFormSubmitButton {
  const UzbekFormSubmitButton(this.onPressed, this.title, {Key? key});

  final String title;
  final VoidCallback onPressed;
  Widget build (BuildContext context) {

    return Container(
      height: 55, 
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lime[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.orangeAccent,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,      // onPressed
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),),
          backgroundColor: WidgetStateProperty.resolveWith((
              Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.redAccent;
            } else {
              return Colors.lime[800];
            }
          }),),
        child: Text(title, style: const TextStyle(
          color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 30,),),
      ),
    );
  }
}



class ButtonWidget extends StatelessWidget {
  final String title;
  final String newRoot;

  const ButtonWidget(this.title, this.newRoot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.lime[800],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
                color: Colors.orange,
              )
      ),
      
      child: ElevatedButton(
        onPressed: () {
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),),
          backgroundColor: WidgetStateProperty.resolveWith((
              Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.redAccent;
            } else {
              return Colors.lime[800];
            }
          }),),
        child: Text(title, style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30,),),
      ),

       
    );
  }
}


/*
Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'Login' : 'Register',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.orangeAccent;
          }
          return Colors.white;
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      ),
    ),
  );
}
*/
