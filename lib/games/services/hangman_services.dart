

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../games/hangman/models/hangman_word_model.dart';

class HangmanService extends GetxService {
  final CollectionReference hangmanReference
  = FirebaseFirestore.instance.collection("games");


  Future<void> addWordsToReviewList({
    required String collectionId,
    required HangmanWordModel wordsData,
  }) async {

    await hangmanReference
        .doc('hangman')
        .collection(collectionId)
        .add(wordsData.toFirestore(),

    ).catchError((error) {
      print("Error adding the words");
      return error;
    });
  }


  Future<HangmanWordModel?> getRandomHangmanWords({
    required String collectionId,
  }) async {
    final randomSeed = Random().nextDouble();

    try {
      final snapshot = await hangmanReference
          .doc('hangman')
          .collection(collectionId)
          .where(Filter('random', isGreaterThanOrEqualTo: randomSeed))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        final wrappedSnapshot = await hangmanReference
            .doc('hangman')
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


}