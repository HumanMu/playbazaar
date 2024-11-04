const { friendRequestNotifications } = require('./push_notification/friendRequestNotifications');
const { privateMessagesNotifications } = require('./push_notification/messageNotification');
const admin = require('firebase-admin');

admin.initializeApp();

// Export the function directly
exports.friendRequestNotifications = friendRequestNotifications;
exports.privateMessagesNotifications = privateMessagesNotifications;
