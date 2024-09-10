import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../games/games/models/question_models.dart';

class FirestoreQuiz {
  final String? userId;
  FirestoreQuiz({this.userId});
  final _db = FirebaseFirestore.instance;

  // reference to the firestore collection
  final CollectionReference quizReference
  = FirebaseFirestore.instance.collection("games");



  Future<void> addQuestionsToReviewList({
    required String quizId,
    required QuizQuestionModel quizData,
    }) async {
      await quizReference.doc('quizz').collection(quizId).add({
      'path': quizData.path,
      'question': quizData.question,
      'correctAnswer': quizData.correctAnswer,
      'wrongAnswers': quizData.wrongAnswers,
      'description': quizData.description,
    }).catchError((error) {
      return error;
    });
  }

  Future<bool> deleteQuestionFromReviewList({
    required String documentId,
  }) async {
    try {
      // Deleting the document from the specified collection
      await quizReference
          .doc('quizz')
          .collection('quetionRequest')
          .doc(documentId)
          .delete();

      return true;
    } catch (e) {
      return false;  // rethrow the error if you want to handle it higher up
    }
  }


  Future<bool> addQuestionToApprovedList({
    required String quizId,
    required QuizQuestionModel quizData,
  }) async {
    final randomValue = Random().nextDouble();

    try {
      await quizReference.doc('quizz').collection(quizId).add({
        'question': quizData.question,
        'correctAnswer': quizData.correctAnswer,
        'wrongAnswers': quizData.wrongAnswers,
        'description': quizData.description,
        'random': randomValue,
      });
      return true;
    } catch (error) {
      return false;
    }
  }



  Future<List<QuizQuestionModel>> getRandomQuizQuestions({
    required String quizId,
    int? numberOfQuetions})
  async {
    // Generate a random number to use as a seed for shuffling
    final randomSeed = Random().nextDouble();
    numberOfQuetions ??= 10;

   // Print below got printed
    final snapshot = await quizReference.doc('quizz').collection('quetionRequest')
        .orderBy('random', descending: false)
        .startAt([randomSeed])
        .limit(numberOfQuetions)
        .get();
    // If the returned list is less than 20, fetch from the beginning
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.docs;
    if (docs.length < 10) {
      final additionalDocs = await quizReference.doc('quizz').collection(quizId)
          .orderBy('random', descending: false)
          .endBefore([randomSeed])
          .limit(10 - docs.length)
          .get();
      docs.addAll(additionalDocs.docs);
    }

    // Map each document snapshot to a QuizzQuestionModel
    return docs.map((doc) {
      final data = doc.data();
      final question = QuizQuestionModel.fromMap(data);
      return question;
    }).toList();
  }

  Future<void> addCountry({
    required String gameId,
    required String quizId,
    required String countryCode,
    required String country,
    required String capital,
    required List<String> wrongCapitals,
    final String? description,
  }) async {
    quizReference.doc(gameId).collection('quizz').doc(quizId)
        .collection('countries').doc(countryCode).set({
      'country': country,
      'capital': capital,
      'wrong_capitals': wrongCapitals,
      'description': description,
    }).catchError((error) {
      if (kDebugMode) {
        print("Failed to add country: $error");
      }
    });
  }


}

