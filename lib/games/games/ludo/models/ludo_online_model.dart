 import 'package:playbazaar/functions/enum_converter.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/games/games/ludo/models/single_online_player.dart';
import '../../../helper/enum.dart';

 class LudoOnlineModel {
   final String gameId;
   final String hostId;
   final bool teamPlay;
   final bool enableRobots;
   final GameProgress gameStatus;
   final String? currentPlayerTurn;
   final int? diceValue;
   final bool canRollDice;
   final List<SingleOnlinePlayer> players;
   final Timestamp? createdAt;
   final Timestamp? lastUpdated;
   final List<SingleOnlinePlayer>? winnerOrder;
   final String gameCode;

   LudoOnlineModel({
     required this.gameId,
     required this.hostId,
     required this.gameCode,
     required this.teamPlay,
     required this.enableRobots,
     required this.gameStatus,
     this.currentPlayerTurn,
     this.diceValue,
     required this.canRollDice,
     required this.players,
     this.createdAt,
     this.lastUpdated,
     this.winnerOrder,
   });

   factory LudoOnlineModel.fromMap(Map<String, dynamic> map) {


     final sPlayers = (map['players'] as List<dynamic>? ?? [])
         .map((e) => SingleOnlinePlayer.fromMap(Map<String, dynamic>.from(e as Map)))
         .toList();

     final winners = (map['winnerOrder'] as List<dynamic>? ?? [])
         .map((e) => SingleOnlinePlayer.fromMap(Map<String, dynamic>.from(e as Map)))
         .toList();

     return LudoOnlineModel(
       gameId: map['gameId'] ?? '',
       hostId: map['hostId'] ?? '',
       teamPlay: map['teamPlay'] ?? false,
       enableRobots: map['enableRobots'] ?? false,
       gameStatus: string2Progress(map['gameStatus']),
       currentPlayerTurn: map['currentPlayerTurn'],
       diceValue: map['diceValue'],
       canRollDice: map['canRollDice'] ?? false,
       players: sPlayers,
       createdAt: map['createdAt'],
       lastUpdated: map['lastUpdated'],
       winnerOrder: winners,
       gameCode: map['gameCode'] ?? '',
     );
   }

   Map<String, dynamic> toMap({bool useServerTimestamps = false}) {
     return {
       'gameId': gameId,
       'hostId': hostId,
       'teamPlay': teamPlay,
       'enableRobots': enableRobots,
       'gameStatus': progress2String(gameStatus),
       'currentPlayerTurn': currentPlayerTurn,
       'diceValue': diceValue,
       'canRollDice': canRollDice,
       'players': players.map((player) => player.toMap()).toList(),
       'createdAt': createdAt?? FieldValue.serverTimestamp(),
       'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
       'winnerOrder': winnerOrder ?? [],
       'gameCode': gameCode,
     };
   }

   LudoOnlineModel copyWith({
     String? gameId,
     String? hostId,
     bool? teamPlay,
     bool? enableRobots,
     GameProgress? gameStatus,
     String? currentPlayerTurn,
     int? diceValue,
     bool? canRollDice,
     List<SingleOnlinePlayer>? players,
     Timestamp? createdAt,
     Timestamp? lastUpdated,
     List<SingleOnlinePlayer>? winnerOrder,
     String? gameCode,
   }) {
     return LudoOnlineModel(
       gameId: gameId ?? this.gameId,
       hostId: hostId ?? this.hostId,
       teamPlay: teamPlay ?? this.teamPlay,
       enableRobots: enableRobots ?? this.enableRobots,
       gameStatus: gameStatus ?? this.gameStatus,
       currentPlayerTurn: currentPlayerTurn ?? this.currentPlayerTurn,
       diceValue: diceValue ?? this.diceValue,
       canRollDice: canRollDice ?? this.canRollDice,
       players: players ?? this.players,
       createdAt: createdAt ?? this.createdAt,
       lastUpdated: lastUpdated ?? this.lastUpdated,
       winnerOrder: winnerOrder,
       gameCode: gameCode ?? this.gameCode,
     );
   }
 }

