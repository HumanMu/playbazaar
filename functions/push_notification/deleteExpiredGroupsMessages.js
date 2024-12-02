const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// It is not sure that this function work and added to the index.js

exports.deleteExpiredMessages = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async (context) => {
    const firestore = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    try {
      // Find chats with active messaging in the last hour
      const activeChatsSnapshot = await firestore
        .collection('chats')
        .where('lastMessageTimestamp', '>', now.toDate().getTime() - (60 * 60 * 1000))
        .limit(500) // Limit to prevent timeout
        .get();

      // Process only active chats
      for (const chatDoc of activeChatsSnapshot.docs) {
        const messagesRef = chatDoc.ref.collection('messages');

        const expiredMessagesQuery = messagesRef
          .where('ttl_timestamp', '<=', now)
          .limit(500);

        const expiredMessagesSnapshot = await expiredMessagesQuery.get();

        // Batch delete expired messages
        if (!expiredMessagesSnapshot.empty) {
          const batch = firestore.batch();
          expiredMessagesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
          });

          await batch.commit();
        }
      }

      console.log('Expired messages cleanup completed');
      return null;
    } catch (error) {
      console.error('Error in message cleanup:', error);
      return null;
    }
  });