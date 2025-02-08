import 'package:playbazaar/games/games/word_connector/models/dto/sharedpreferences_dto.dart';
import '../games/word_connector/models/add_word_model.dart';
import '../games/word_connector/models/word_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class WordConnectorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentReference _gameCollection
  = FirebaseFirestore.instance.collection("games").doc('word_connector');
  final String _gameDirectory = 'connector_';

  // Default game data
  final Map<String, dynamic> _defaultData = {
    "words": ["HELL","WORD","HELLO", "WORLD"],
    "letters": ["H", "E", "L","L", "W", "R", "D", "O"],
    'level': 1,
  };

  Future<WordConnectorDto> getConnectorWords(SharedpreferencesDto pref) async {
    String directory = "$_gameDirectory${pref.language}";
    try {

      print("Recieved parameters: ${pref.toJson()}");
      final CollectionReference gameCollection = _gameCollection
          .collection(directory)
          .doc("levels")
          .collection("level_${pref.level}");

      final QuerySnapshot querySnapshot = await gameCollection
          .where("count", isEqualTo: pref.count)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return _parseGameData(data);
      } else {
        debugPrint('No document found matching count: ${pref.count}');
      }
    } catch (e) {
      debugPrint('Error fetching from Firestore: $e');
    }

    try {
      return _parseGameData(_defaultData);
    } catch (e) {
      debugPrint('Error parsing default data: $e');
      return WordConnectorDto(words: [], letters: [], level: 1);
    }
  }

  WordConnectorDto _parseGameData(Map<String, dynamic> data) {
    return WordConnectorDto(
      words: (data['words'] as List)
          .map((w) => WordConnectorModel(text: w as String))
          .toList(),
      letters: List<String>.from(data['letters']),
      level: data['level'],
    );
  }

  Future<AddWordModel?> getWordByCount(String language, int level, int count) async {
    String directory = "$_gameDirectory$language";

    try {
      final CollectionReference collection = FirebaseFirestore.instance
          .collection(directory)
          .doc("levels")
          .collection("level_$level");

      QuerySnapshot querySnapshot = await collection
          .where('count', isEqualTo: count)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return AddWordModel.fromFirestore(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch word by count: $e');
    }
  }




  Future<void> addWord(AddWordModel words, String language) async {
    String directory = "$_gameDirectory$language";

    try {
      final CollectionReference collection = _gameCollection
          .collection(directory)
          .doc("levels")
          .collection("level_${words.level}");

      AggregateQuerySnapshot countSnapshot = await collection.count().get();
      int length = countSnapshot.count?? 0;
      words.count = length +1;

      await collection.add(words.toFirestore());

    } catch (e) {
      throw Exception('Failed to add word: $e');
    }
  }

}
