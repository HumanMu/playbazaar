import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../avatars/secondry_avatar.dart';

class RecievedRequestsTile extends StatefulWidget {
  final String fullname;
  final String? availabilityState;
  final String? avatarImage;
  final Function()? acceptAction;
  final Function()? declineAction;


  const RecievedRequestsTile({super.key,
    required this.fullname,
    this.avatarImage,
    this.availabilityState,
    this.acceptAction,
    this.declineAction,

  });

  @override
  State<RecievedRequestsTile> createState() => _RecievedRequestsTileState();
}

class _RecievedRequestsTileState extends State<RecievedRequestsTile> {
  String onlineStatus = "";



  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SecondaryAvatar(avatarImage: widget.fullname),
              Column(
                children: [
                  Text(widget.fullname),
                  Text("${"status".tr}  ${widget.availabilityState?? "offline".tr}",
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: widget.acceptAction,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),

                ),
                //style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text('btn_accept'.tr, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: widget.declineAction,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red)),
                child: Text('btn_decline'.tr, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 15),
            ],
          )
        ],
      ),
    );
  }
}

/*
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.red,
            child: Text(
              widget.fullname.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          title: Text(widget.fullname,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text("${"status".tr}${widget.availabilityState}",
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
        ),
      );
 */
