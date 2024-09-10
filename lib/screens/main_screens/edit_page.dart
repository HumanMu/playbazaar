import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import '../../helper/sharedpreferences.dart';
import '../../languages/custom_language.dart';
import '../widgets/avatars/primary_avatar.dart';
import '../widgets/header.dart';
import '../widgets/text_boxes/text_inputs.dart';
// retrieving user info

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  /*final String firstname;
  final String lastname;
  final String email;
  final String? aboutme;

  const EditPage({ super.key,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.aboutme
  });*/

  @override
  State<EditPage> createState() => _EditPage();
}

class _EditPage extends State<EditPage> {

  String email = "";
  String firstname = "";
  String lastname = "";
  String aboutme = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _profileInformation(context),
    );
  }

  getInformation() async {
    final value = await SharedPreferencesManager.getString(SharedPreferencesKeys.userEmailKey);
    if(value != null && value != "") {
      setState(() {
        email = value;
      });
    }
  }


  Widget _profileInformation(context) {
    final firstnameCon = TextEditingController(text: firstname);
    final lastnameCon = TextEditingController();
    final emailCon = TextEditingController(text: email);
    final aboutCon = TextEditingController();

    return CustomScrollView(
      scrollDirection: Axis.vertical,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: ClipPath(
                      clipper: Header(),
                      child: Container(
                        color: Colors.limeAccent,
                        height: 205,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: Header(),
                    child: Container(
                      color: Colors.redAccent,
                      height: 185,
                      alignment: Alignment.centerLeft,
                      child: const PrimaryAvatarImage(editing: false),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () { CustomLanguage().languageDialog(context); },
                        child: Text('language'.tr,
                            style: const TextStyle(color: Colors.red)),
                      )
                  ),
                  Text('aboutme'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 45)),
                  Form(
                    autovalidateMode: AutovalidateMode.always,
                    onChanged: () {
                      setState(() {
                        Form.of(primaryFocus!.context!).save();
                      });
                    },
                    child: Column(
                      children: [
                        /*CustomTextInputs(value: widget.firstname, edit: false),
                        CustomTextInputs(value: widget.email, edit: false),
*/
                        CustomTextFormField(initialVal: firstname),
                        CustomTextFormField(initialVal: lastname),
                      ],
                    ),
                  ),
                  const SizedBox( height: 40 ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    height: 50,
                    child: SizedBox(
                      width: 80,
                      height: 40,
                      child: _saveButton(),
                    ),
                  ), // Edit and chatpage buttons
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _saveButton() {
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        backgroundColor:
        WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.redAccent;
          } else {
            return Colors.lime[800];
          }
        }),
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ProfilePage()));
      },
      child: Text( 'btn_save'.tr ),
    );
  }
}
