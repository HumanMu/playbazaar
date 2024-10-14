import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const updateFriendInfo = functions.firestore
    .document('usersCollection/{userId}')
    .onUpdate(async (change, context) => {
        const updatedUserData = change.after.data();
        const userId = context.params.userId;

        const displayName = updatedUserData?.displayName;
        const photoURL = updatedUserData?.photoURL;

        const snapshot = await admin.firestore().collectionGroup('friends')
            .where('uid', '==', userId)
            .get();

        const batch = admin.firestore().batch();

        snapshot.forEach(doc => {
            const friendDocRef = doc.ref;
            batch.update(friendDocRef, { displayName, photoURL });
        });

        return batch.commit();
    });
