 import 'package:playbazaar/functions/enum_converter.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
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
   final List<dynamic> gameTokens;
   final Map<String, dynamic> teamAssignments;
   final Timestamp? createdAt;
   final Timestamp? lastUpdated;
   final List<dynamic> winnerOrder;
   final String gameCode;

   LudoOnlineModel({
     required this.gameId,
     required this.hostId,
     required this.teamPlay,
     required this.enableRobots,
     required this.gameStatus,
     this.currentPlayerTurn,
     this.diceValue,
     required this.canRollDice,
     required this.gameTokens,
     required this.teamAssignments,
     this.createdAt,
     this.lastUpdated,
     required this.winnerOrder,
     required this.gameCode,
   });

   factory LudoOnlineModel.fromMap(Map<String, dynamic> map) {
     List<dynamic> gameTokensList;

     if (map['gameTokens'] is List) {
       gameTokensList = List.from(map['gameTokens']);
     } else if (map['gameTokens'] is Map) {
       // Convert Map to List
       Map<String, dynamic> tokensMap = Map<String, dynamic>.from(map['gameTokens']);
       gameTokensList = List.filled(16, null); // Adjust size as needed
       tokensMap.forEach((key, value) {
         int index = int.tryParse(key) ?? 0;
         if (index < gameTokensList.length) {
           gameTokensList[index] = value;
         }
       });
     } else {
       gameTokensList = [];
     }


     return LudoOnlineModel(
       gameId: map['gameId'] ?? '',
       hostId: map['hostId'] ?? '',
       teamPlay: map['teamPlay'] ?? false,
       enableRobots: map['enableRobots'] ?? false,
       gameStatus: string2Progress(map['gameStatus']),
       currentPlayerTurn: map['currentPlayerTurn'],
       diceValue: map['diceValue'],
       canRollDice: map['canRollDice'] ?? false,
       gameTokens: gameTokensList,
       teamAssignments: Map<String, dynamic>.from(map['teamAssignments'] ?? {}),
       createdAt: map['createdAt'],
       lastUpdated: map['lastUpdated'],
       winnerOrder: List.from(map['winnerOrder'] ?? []),
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
       'gameTokens': gameTokens,
       'teamAssignments': teamAssignments,
       'createdAt': createdAt?? FieldValue.serverTimestamp(),
       'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
       'winnerOrder': winnerOrder,
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
     List<dynamic>? gameTokens,
     List<dynamic>? activeTokenTypes,
     Map<String, dynamic>? teamAssignments,
     Timestamp? createdAt,
     Timestamp? lastUpdated,
     List<dynamic>? winnerOrder,
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
       gameTokens: gameTokens ?? this.gameTokens,
       teamAssignments: teamAssignments ?? this.teamAssignments,
       createdAt: createdAt ?? this.createdAt,
       lastUpdated: lastUpdated ?? this.lastUpdated,
       winnerOrder: winnerOrder ?? this.winnerOrder,
       gameCode: gameCode ?? this.gameCode,
     );
   }
 }

