const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { logger } = require('firebase-functions');


exports.privateMessagesNotifications = onDocumentCreated(
    {
        document: 'privateMessages/{chatId}/messages/{messageId}',
        region: 'europe-west3',
    },
    async (event) => {
        const messageData = event.data.data();
        const recipientId = messageData.recipientId;
        const senderId = messageData.senderId;
        const messageContent = messageData.text;
        const senderName = messageData.senderName || "Someone";

        try {
            // Get all active devices for the recipient
            const devicesSnapshot = await getFirestore()
                .collection(`users/${recipientId}/devices`)
                .where('fcmNewMessages', '==', true)
                .where('isActive', '==', true)  // Add this condition
                .where('fcmToken', '!=', null)  // Ensure token exists
                .get();

            if (devicesSnapshot.empty) {
                logger.warn("No active devices found for recipient");
                return;
            }

            // Collect all FCM tokens for active devices
            const fcmTokens = devicesSnapshot.docs
                .map((doc) => doc.data().fcmToken)
                .filter((token) => token);

            if (fcmTokens.length === 0) {
                logger.warn("No valid FCM tokens found for recipient devices");
                return;
            }

            // Data-only message structure
            const message = {
                tokens: fcmTokens,
                data: {
                    body: messageContent,
                    senderId: senderId,
                    senderName: senderName,
                    channelId: 'new_message',
                    route: '/friendsList',
                    timestamp: Date.now().toString(),
                    type: 'private_message'
                }
            };

            // Send the multicast message
            const response = await getMessaging().sendEachForMulticast(message);

            // Log success and handle invalid tokens
            const failureCount = response.failureCount;
            const successCount = response.successCount;
            logger.info(`Sent notifications: ${successCount} successful, ${failureCount} failed`);

            if (failureCount > 0) {
                const invalidTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        logger.error(`Error sending to token ${fcmTokens[idx]}:`, resp.error);
                        if (resp.error?.code === 'messaging/invalid-registration-token' ||
                            resp.error?.code === 'messaging/registration-token-not-registered') {
                            invalidTokens.push(devicesSnapshot.docs[idx].ref);
                        }
                    }
                });

                // Remove invalid tokens in batch
                if (invalidTokens.length > 0) {
                    const batch = getFirestore().batch();
                    invalidTokens.forEach((ref) => batch.delete(ref));
                    await batch.commit();
                    logger.info(`Removed ${invalidTokens.length} invalid tokens`);
                }
            }

        } catch (error) {
            logger.error("Error processing message notification:", error);
            throw new Error(`Failed to send notifications: ${error.message}`);
        }
    }
);
