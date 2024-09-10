import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:get/get.dart';
import '../../api/Authentication/auth_service.dart';
import '../../api/Firestore/firestore_groups.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences.dart';
import '../../shared/show_custom_snackbar.dart';
import '../../utils/notfound.dart';
import '../../utils/text_boxes/text_box_decoration.dart';
import '../secondary_screens/search_page.dart';
import '../widgets/cards/custom_group_tile.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/text_boxes/text_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  final String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String userName = "";
  String userEmail = "";
  Stream? userSnapshot;
  Stream<DocumentSnapshot>? userFriends;
  Stream? friendsRequests;
  bool newFriendRequest = false;
  bool _isLoading = false;
  String groupName = "";
  String? groupPassword = "";
  final groupNameController = TextEditingController();
  final groupPasswordController = TextEditingController();
  bool theme = false;
  final _controller = ValueNotifier<bool>(false);
  bool value = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    getFriends();
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  List<String> getName(String group) {
    var parts = group.split('_');
    //String result = parts[1].trim();
    return parts;
  }

  getUserData() async {
    final name = await SharedPreferencesManager.getString(
        SharedPreferencesKeys.userNameKey);
    if (name != null && name != "") {
      setState(() {
        userName = name;
      });
    }
    final email = await SharedPreferencesManager.getString(
        SharedPreferencesKeys.userEmailKey);
    if (email != null && email != "") {
      setState(() {
        userEmail = email;
      });
    }

    userSnapshot = await FirestoreGroups(userId: currentUserId).getGroupsList();
  }

  getFriends() async {
    userFriends = await FirestoreUser(userId: currentUserId).getFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              navigateToAnotherScreen(
                  context, const SearchPage(searchId: 'group'));
            },
            icon: const Icon(Icons.search),
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          "my_memberships".tr,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      drawer: SidebarDrawer(
        authService: authService,
        parentContext: context,
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.red, size: 30),
      ),
    );
  }

  groupList() {
    return StreamBuilder(
      stream: userSnapshot,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && snapshot.data['groups'] != null) {
          // If snapshot contain data og 'group'
          if (snapshot.data['groups'].length != 0) {
            return ListView.builder(
              itemCount: snapshot.data['groups'].length,
              itemBuilder: (context, index) {
                int reverseIndex = snapshot.data['groups'].length -
                    index -
                    1; // For not showing the group id
                final user = snapshot.data['groups'];
                return CustomGroupTile(
                  groupId: getId(user[reverseIndex]),
                  groupName: getName(user[reverseIndex])[1].trim(),
                  admin: userName,
                  password: getName(user[reverseIndex])[2].trim(),
                );
              },
            );
          } else {
            return notFound("not_found_title".tr, "not_found_message".tr);
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        }
      },
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            _controller.addListener(() {
              setState(() {
                value = _controller.value;
              });
            });
            return AlertDialog(
                title: Text("create_group_title".tr),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading == true
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: Colors.red,
                          ))
                        : TextField(
                            controller: groupNameController,
                            onChanged: (val) {
                              groupName = val;
                              setState(() {});
                            },
                            decoration: decoration("group_name_hint".tr),
                          ),
                    privatePublicToggler(_controller),
                    Visibility(
                      visible: value,
                      child: TextField(
                        controller: groupPasswordController,
                        onChanged: (val) {
                          groupPassword = val;
                        },
                        decoration: decoration("group_password_hint".tr),
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("btn_cancel".tr),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (groupNameController.text != "") {
                        setState(() {
                          _isLoading = true;
                        });
                        FirestoreGroups(
                                userId: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                          userName,
                          FirebaseAuth.instance.currentUser!.uid,
                          groupNameController.text,
                          groupPassword,
                        )
                            .whenComplete(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                        showCustomSnackbar("group_created".tr, true);
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("btn_create".tr),
                  ),
                ]);
          }));
        });
  }

  privatePublicToggler(controller) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: AdvancedSwitch(
        controller: controller,
        enabled: true,
        height: 35,
        width: 100,
        borderRadius: const BorderRadius.all(Radius.circular(120)),
        inactiveColor: Colors.green,
        activeColor: Colors.red,
        inactiveChild: Text('private'.tr),
        activeChild: Text('public'.tr),
        thumb: ValueListenableBuilder<bool>(
            valueListenable: controller,
            builder: (context, value, child) {
              return Icon(
                controller.value
                    ? Icons.security_outlined
                    : Icons.public_outlined,
                size: 30,
              );
            }),
      ),
    );
  }
}
