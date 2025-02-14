
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'game_participiant.dart';

class OnlineCompetitionDocModel {
  String gameId;
  String inviteCode;
  String hostId;
  List<GameParticipantModel> participants;
  int? maxParticipants;
  String gameState;
  String wordToGuess;
  String? wordHint;
  GameParticipantModel? winner;
  Timestamp createdAt;

  OnlineCompetitionDocModel({
    required this.gameId,
    required this.inviteCode,
    required this.hostId,
    required this.participants,
    this.maxParticipants = 8,
    required this.gameState,
    required this.wordToGuess,
    this.wordHint,
    this.winner,
    required this.createdAt,
  });



  factory OnlineCompetitionDocModel.fromFirestore(Map<String, dynamic> map) {

    List<GameParticipantModel> gameParticipants = [];
    if (map['participants'] != null) {
      try {
        gameParticipants = (map['participants'] as List)
            .map((participant) => GameParticipantModel.fromFirestore(
            participant as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error parsing participants: model');
      }
    }


    GameParticipantModel? winner;
    if (map['winner'] != null) {
      try {
        winner = GameParticipantModel.fromFirestore(map['winner'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing winner: model');
      }
    }

    return OnlineCompetitionDocModel(
      gameId: map['gameId']?.toString() ?? '',
      inviteCode: map['inviteCode']?.toString() ?? '',
      hostId: map['hostId']?.toString() ?? '',
      participants: gameParticipants,
      maxParticipants: map['maxParticipants'] as int? ?? 10,
      gameState: map['gameState']?.toString() ?? 'initial',
      wordToGuess: map['wordToGuess']?.toString() ?? '',
      wordHint: map['wordHint']?.toString() ?? '',
      winner: winner,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );

  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'inviteCode': inviteCode,
      'hostId': hostId,
      'participants': participants.map((p) => p.toFirestore()).toList(),
      'maxParticipants': maxParticipants,
      'gameState': gameState,
      'wordToGuess': wordToGuess,
      'winner': winner?.toFirestore(),
      'createdAt': createdAt,
      'wordHint': wordHint,
    };
  }

}