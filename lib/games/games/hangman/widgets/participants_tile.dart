import 'package:flutter/material.dart';
import '../models/game_participiant.dart';

class ParticipantListTile extends StatelessWidget {
  final GameParticipantModel participant;
  final bool isHost;

  const ParticipantListTile({
    super.key,
    required this.participant,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatar(),
      title: Text(
        participant.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: isHost ? _buildHostChip() : null,
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundImage: participant.image != null
          ? NetworkImage(participant.image!)
          : null,
      child: participant.image == null
          ? Text(participant.name[0].toUpperCase())
          : null,
    );
  }

  Widget _buildHostChip() {
    return const Chip(
      label: Text('Host'),
      backgroundColor: Colors.blue,
      labelStyle: TextStyle(color: Colors.white),
    );
  }
}
