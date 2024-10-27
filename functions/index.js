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

exports.newRequestNotification = functions.firestore
    .document("requests/{requestId}")
    .onCreate(async (snapshot, context) => {
      const requestID = context.params.requestId;
      const requestData = snapshot.data();
      if (!requestData) {
        console.log("No request data found");
        return null;
      }
      const ownerID = requestData.ownerID;
      const ownerDoc = await firestore.doc(`users/${ownerID}`).get();

      const applicantID = requestData.applicantID;
      const applicantDoc = await firestore.doc(`users/${applicantID}`).get();

      if (!ownerDoc.exists || !applicantDoc.exists) {
        console.log("Owner or applicant does not exist");
        return null;
      }

      const ownerData = ownerDoc.data();
      const applicantData = applicantDoc.data();

      if (!ownerData || !applicantData) {
        console.log("No owner or applicant data");
        return null;
      }

      const ownerToken = ownerData.token;
      const applicantName = applicantData.fullName;

      const itemID = requestData.itemID;
      const itemDoc = await firestore.doc(`items/${itemID}`).get();
      if (!itemDoc.exists) {
        console.log("Item does not exist");
        return null;
      }
      const itemData = itemDoc.data();
      if (!itemData) {
        console.log("No item data");
        return null;
      }
      const itemTitle = itemData.title;

      const payload = {
        notification: {
          title: `התקבלה בקשה חדשה`,
          body: `${applicantName} רוצה להשכיר את ה${itemTitle} שלך`,
        },
        data: {
          chatId: requestID,
        },
        token: ownerToken,
      };

      try {
        const response = await messaging.send(payload);
        console.log("Successfully sent notification:", response);
      } catch (error) {
        console.error("Error sending notification:", error);
      }
      return null;
    });


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

      const senderUid = null;
      const recipientUid = null;

      Object.keys(participants).forEach((uid) => {
        if (participants[uid].index == senderIndex) {
          senderUid = uid;
        } else {
          recipientUid = uid;
        }
      });

      if (!senderUid || !recipientUid) {
        console.log("Sender or recipient does not found in chat");
        return null;
      }

      const senderDoc = await firestore.doc(`users/${senderUid}`).get();
      const recipientDoc = await firestore.doc(`users/${senderUid}`).get();

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
          title: senderName,
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
