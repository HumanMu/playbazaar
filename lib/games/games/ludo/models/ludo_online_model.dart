 import 'package:playbazaar/functions/enum_converter.dart';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/games/games/ludo/models/single_online_player.dart';
import '../../../helper/enum.dart';

 class LudoOnlineModel {
   final String gameId;
   final String hostId;
   final bool teamPlay;
   final bool enableRobots;
   final GameProgress gameState;
   final String? currentPlayerTurn;
   final int? diceValue;
   final Map<String, SingleOnlinePlayer> players;
   final Timestamp? createdAt;
   final Timestamp? lastUpdated;
   final List<String>? winnerOrder;
   final String gameCode;
   final Map<String, int>? tokens;

   LudoOnlineModel({
     required this.gameId,
     required this.hostId,
     required this.gameCode,
     required this.teamPlay,
     required this.enableRobots,
     required this.gameState,
     this.currentPlayerTurn,
     this.diceValue,
     required this.players,
     this.createdAt,
     this.lastUpdated,
     this.winnerOrder,
     this.tokens,
   });

   factory LudoOnlineModel.fromMap(Map<String, dynamic> map) {
     final rawPlayers = map['players'] as Map<String, dynamic>? ?? {};
     final playersMap = rawPlayers.map(
           (playerId, data) => MapEntry(
         playerId,
         SingleOnlinePlayer.fromMap(Map<String, dynamic>.from(data)),
       ),
     );

     final winners = (map['winnerOrder'] as List<dynamic>? ?? [])
         .map((e) => e.toString())
         .toList();

     // Parse tokens map
     Map<String, int>? tokensMap;
     if (map['tokens'] != null) {
       tokensMap = Map<String, int>.from(map['tokens']);
     }

     return LudoOnlineModel(
       gameId: map['gameId'] ?? '',
       hostId: map['hostId'] ?? '',
       teamPlay: map['teamPlay'] ?? false,
       enableRobots: map['enableRobots'] ?? false,
       gameState: string2Progress(map['gameState']),
       currentPlayerTurn: map['currentPlayerTurn'],
       diceValue: map['diceValue'],
       players: playersMap,
       createdAt: map['createdAt'],
       lastUpdated: map['lastUpdated'],
       winnerOrder: winners,
       gameCode: map['gameCode'] ?? '',
       tokens: tokensMap,
     );
   }

   Map<String, dynamic> toMap({bool useServerTimestamps = false}) {
     return {
       'gameId': gameId,
       'hostId': hostId,
       'teamPlay': teamPlay,
       'enableRobots': enableRobots,
       'gameState': progress2String(gameState),
       'currentPlayerTurn': currentPlayerTurn,
       'diceValue': diceValue,
       'players': players.map(
             (playerId, player) => MapEntry(playerId, player.toMap()),
       ),
       'createdAt': createdAt ?? FieldValue.serverTimestamp(),
       'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
       'winnerOrder': winnerOrder ?? [],
       'gameCode': gameCode,
       'tokens': tokens ?? {},
     };
   }

   LudoOnlineModel copyWith({
     String? gameId,
     String? hostId,
     bool? teamPlay,
     bool? enableRobots,
     GameProgress? gameState,
     String? currentPlayerTurn,
     int? diceValue,
     bool? canRollDice,
     Map<String, SingleOnlinePlayer>? players,
     Timestamp? createdAt,
     Timestamp? lastUpdated,
     List<String>? winnerOrder,
     String? gameCode,
     Map<String, int>? tokens,
   }) {
     return LudoOnlineModel(
       gameId: gameId ?? this.gameId,
       hostId: hostId ?? this.hostId,
       teamPlay: teamPlay ?? this.teamPlay,
       enableRobots: enableRobots ?? this.enableRobots,
       gameState: gameState ?? this.gameState,
       currentPlayerTurn: currentPlayerTurn ?? this.currentPlayerTurn,
       diceValue: diceValue ?? this.diceValue,
       players: players ?? this.players,
       createdAt: createdAt ?? this.createdAt,
       lastUpdated: lastUpdated ?? this.lastUpdated,
       winnerOrder: winnerOrder,
       gameCode: gameCode ?? this.gameCode,
       tokens: tokens ?? this.tokens,
     );
   }
 }
