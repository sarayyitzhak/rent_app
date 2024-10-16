/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
admin.initializeApp();
const firestore = admin.firestore();
const messaging = admin.messaging();

exports.sendChatNotification = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snapshot, context) => {
      const chatId = context.params.chatId;
      const messageData = snapshot.data();

      if (!messageData) {
        console.log("No message data found");
        return null;
      }
      const chatDoc = await firestore.doc(`chats/${chatId}`).get();
      const chatData = chatDoc.data();

      if (!chatData || !chatData.participants) {
        console.log("No participants found in chat");
        return null;
      }
      const participants = chatData.participants;
      const senderIndex = messageData.sender;

      const senderDocRef = participants[senderIndex];
      const recipientDocRef = participants[1 - senderIndex];

      const senderDoc = await senderDocRef.get();
      const recipientDoc = await recipientDocRef.get();
      if (!senderDoc.exists || !recipientDoc.exists) {
        console.log("Sender or recipient does not exist");
        return null;
      }
      const senderData = senderDoc.data();
      const recipientData = recipientDoc.data();
      if (!senderData || !recipientData) {
        console.log("No sender or recipient data");
        return null;
      }

      const senderName = senderData.fullName;
      const recipientFCMToken = recipientData.token;

      const payload = {
        notification: {
          title: `הודעה חדשה מ${senderName}`,
          body: messageData.text || "You have received a new message",
        },
        data: {
          chatId: context.params.chatId,
        },
        token: recipientFCMToken,
      };

      try {
        const response = await messaging.send(payload);
        console.log("Successfully sent notification:", response);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
      return null;
    });

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
