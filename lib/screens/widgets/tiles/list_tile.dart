import 'package:flutter/material.dart';
import '../../../api/Authentication/auth_service.dart';

class ListTileWidget extends StatefulWidget{
  final Color? iconColor;
  final String title;
  final IconData? icon;
  final int? length;
  final bool? hasFriends;
  final bool boldTitle;
  final Function()? action;

  const ListTileWidget({super.key,
    this.iconColor,
    required this.title,
    this.icon,
    this.action,
    this.length,
    this.hasFriends,
    this.boldTitle = false
  });

  @override
  State<ListTileWidget> createState() => _ListTileState();
}

class _ListTileState extends State<ListTileWidget> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: widget.action,
      selectedColor: widget.iconColor,
      selected: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
      leading: Icon(widget.icon),
      title: Text(widget.hasFriends == true? '${widget.title}   ${widget.length.toString()}' : widget.title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: widget.boldTitle? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
