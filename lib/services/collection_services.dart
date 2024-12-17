import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionServices {

  Future<bool> deleteCollection(CollectionReference collecctionRef, String collectionName, String documentId) async {
    if (documentId.isEmpty) {
      return false;
    }

    final DocumentReference docRef = collecctionRef.doc(documentId);
    final CollectionReference messagesRef = docRef.collection(collectionName);

    try {
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        return false;
      }

      // Get total count of messages for logging
      final QuerySnapshot countSnapshot = await messagesRef.get();
      final int totalMessages = countSnapshot.size;

      if (totalMessages == 0) {
        await docRef.delete();
        return true;
      }

      // Delete messages in smaller batches
      const int batchSize = 50;
      int deletedCount = 0;

      while (true) {
        final QuerySnapshot batch = await messagesRef.limit(batchSize).get();

        if (batch.docs.isEmpty) {
          break;
        }

        final WriteBatch writeBatch = FirebaseFirestore.instance.batch();
        for (final doc in batch.docs) {
          writeBatch.delete(doc.reference);
        }

        await writeBatch.commit();
        deletedCount += batch.docs.length;

        // Small delay to prevent overloading
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Final verification
      final verificationSnapshot = await messagesRef.limit(1).get();
      if (verificationSnapshot.docs.isEmpty) {
        await docRef.delete();
        return true;
      } else {
        return false;
      }

    } catch (e) {
      print("Error in deletePrivateMessageCollection");
      return false;
    }
  }
}
