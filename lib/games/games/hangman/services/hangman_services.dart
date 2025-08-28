
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/hangman/models/game_participiant.dart';
import 'package:playbazaar/games/games/hangman/models/game_state_change_model.dart';
import '../models/hangman_word_model.dart';
import '../models/online_competition_doc_model.dart';

class HangmanService extends GetxService {
  final DocumentReference hangmanReference
  = FirebaseFirestore.instance.collection("games").doc('hangman');


  Future<void> addWordsToReviewList({
    required String collectionId,
    required HangmanWordModel wordsData,
  }) async {

    await hangmanReference
        .collection(collectionId)
        .add(wordsData.toFirestore(),

    ).catchError((error) {
      debugPrint("Error adding the words");
      return error;
    });
  }


  Future<HangmanWordModel?> getRandomHangmanWords({
    required String collectionId,
  }) async {
    final randomSeed = Random.secure().nextDouble();

    try {
      final snapshot = await hangmanReference
          .collection(collectionId)
          .where(Filter('random', isGreaterThanOrEqualTo: randomSeed))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        final wrappedSnapshot = await hangmanReference
            .collection(collectionId)
            .where(Filter('random', isGreaterThanOrEqualTo: 0))
            .limit(1)
            .get();


        if (wrappedSnapshot.docs.isEmpty) return null;
        return HangmanWordModel.fromFirestore(wrappedSnapshot.docs.first.data());
      }

      return HangmanWordModel.fromFirestore(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }


  Future<bool> createJoinableHangmanGame(String inviteCode, String word, String? hint) async {
    final DocumentReference gameRef = hangmanReference.collection('inProgressGames').doc();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final participant = GameParticipantModel(
        uid: user.uid,
        name: user.displayName ?? "",
        image: user.photoURL,
        numberOfWin: 0,
        gameState: 'Play'
      );

      OnlineCompetitionDocModel gameData = OnlineCompetitionDocModel(
        gameId: gameRef.id,
        inviteCode: inviteCode,
        hostId: user.uid,
        participants: [participant],
        gameState: "waiting",
        wordToGuess: word,
        createdAt: Timestamp.now(),
        wordHint: hint ?? "",
      );

      await gameRef.set(gameData.toFirestore());
      return true;

    }catch(e){
      debugPrint("Creating game ends with an error: $e");
      return false;
    }
  }


  Future<bool> joinGame(String inviteCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Find the game with the invite code
      final querySnapshot = await hangmanReference
          .collection('inProgressGames')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final gameDoc = querySnapshot.docs.first;
      final gameData = OnlineCompetitionDocModel.fromFirestore(gameDoc.data());

      // Check if user is already in the game
      if (gameData.participants.any((p) => p.uid == user.uid)) {
        debugPrint("User already in the game");
        return true;
      }

      if (gameData.participants.length >= (gameData.maxParticipants ?? 8)) {
        return false;
      }

      final newParticipant = GameParticipantModel(
        uid: user.uid,
        name: user.displayName ?? "",
        image: user.photoURL,
        numberOfWin: 0,
        gameState: 'Play',
      );

      await gameDoc.reference.update({
        'participants': FieldValue.arrayUnion([newParticipant.toFirestore()]),
      });

      return true;
    } catch (e) {
      debugPrint("Error joining game: $e");
      return false;
    }
  }

  Stream<OnlineCompetitionDocModel?> streamGameByInviteCode(String inviteCode) {
    return hangmanReference
        .collection('inProgressGames')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      try {
        return OnlineCompetitionDocModel.fromFirestore(
            snapshot.docs.first.data()
        );
      } catch (e) {
        debugPrint('Error parsing game data: $e');
        return null;
      }
    });
  }


  Future<bool> handleGameWin(String gameId, List<GameParticipantModel> participants) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      List<GameParticipantModel> updatedParticipants = participants.map((participant) {
        if (participant.uid == user.uid) {
          return participant.copyWith(
            numberOfWin: participant.numberOfWin + 1
          );
        }
        return participant;
      }).toList();

      // Prepare update data
      Map<String, dynamic> updateData = {
        'gameState': 'waiting',
        'winner': updatedParticipants.firstWhere(
                (p) => p.uid == user.uid).toFirestore(),
        'participants': updatedParticipants.map(
                (p) => p.toFirestore()).toList(),
        'wordHint': '',
        'wordToGuess': '',
      };

      await hangmanReference
          .collection('inProgressGames')
          .doc(gameId)
          .update(updateData);
      return true;
    } catch (e) {
      debugPrint("Error updating game state: $e");
      return false;
    }
  }

  Future<bool> gameLost(String gameId, List<GameParticipantModel> participants) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      List<GameParticipantModel> updatedParticipants = participants.map((participant) {
        if (participant.uid == user.uid) {
          return participant.copyWith(
            gameState: 'Lost',
          );
        }
        return participant;
      }).toList();

      // Prepare update data
      Map<String, dynamic> updateData = {
        'participants': updatedParticipants.map(
                (p) => p.toFirestore()).toList(),
      };

      await hangmanReference
          .collection('inProgressGames')
          .doc(gameId)
          .update(updateData);

      return true;
    } catch (e) {
      debugPrint("Error incrementing gameLost: $e");
      return false;
    }
  }

  Future<bool> handleNextGameStart(GameStateChangeModel nextGameData, List<GameParticipantModel>  participants) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      List<GameParticipantModel> updatedParticipants = participants.map((participant) {
        return participant.copyWith(gameState: 'Play');
      }).toList();

      Map<String, dynamic> updateData = {
        'gameState': 'playing',
        'winner': null,
        'wordHint': nextGameData.wordHint,
        'wordToGuess': nextGameData.word,
        'participants': updatedParticipants.map((participant) => participant.toFirestore()).toList(),
      };

      await hangmanReference
          .collection('inProgressGames')
          .doc(nextGameData.gameId)
          .update(updateData);
      return true;
    } catch (e) {
      debugPrint("Error updating game state: $e");
      return false;
    }
  }


  Future<bool> removeUserOrDestroyGame(String gameId, String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final gameDoc = await hangmanReference
          .collection('inProgressGames')
          .doc(gameId)
          .get();

      if (gameDoc.exists) {
        List<dynamic> participants = gameDoc['participants'];
        String hostId = gameDoc['hostId'];

        if (hostId == userId) {
          await hangmanReference
              .collection('inProgressGames')
              .doc(gameId)
              .delete();

        } else {
          participants.removeWhere((participant) => participant['uid'] == userId);

          await hangmanReference
              .collection('inProgressGames')
              .doc(gameId)
              .update({
            'participants': participants,
          });
        }
      }

      return true;
    } catch (e) {
      debugPrint("Error in removeOrDestroyGame: $e");
      return false;
    }
  }

}
