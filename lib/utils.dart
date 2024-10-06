

class Location{
    String cityName;
    String streetName;
    Location(this.cityName, this.streetName);
    //coordinates;
}




//**
//  * Import function triggers from their respective submodules:
//  *
//  * import {onCall} from "firebase-functions/v2/https";
//  * import {onDocumentWritten} from "firebase-functions/v2/firestore";
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */
//
// // import {onRequest} from "firebase-functions/v2/https";
// // import * as logger from "firebase-functions/logger";
//
// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript
//
// // export const helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });
//
//
// import * as functions from "firebase-functions";
// import * as admin from "firebase-admin";
//
// // Initialize Firebase Admin SDK
// admin.initializeApp();
// const db = admin.firestore();
// const fcm = admin.messaging();
//
// // Firestore document trigger on new message creation
// export const sendChatNotification = functions.firestore
//   .document("chats/{chatId}/messages/{messageId}")
//   .onCreate(async (snapshot, context) => {
//     const message = snapshot.data();
//     const chatId = context.params.chatId;
//
//     // Extract necessary fields
//     const senderIdx = message.sender;
//     const messageText = message.text;
//
//     try {
//       const chatDoc = await db.collection("chats").doc(chatId).get();
//       const chatData = chatDoc.data();
//       const participants = chatData?.participants;
//       const senderRef = participants[senderIdx];
//       const recipientRef=participants[(senderIdx+1)%2];
//       const senderDoc = await senderRef.get();
//       // const senderDoc=await db.collection("users").doc().get();
//       const senderData = senderDoc.data();
//       const senderName = senderData.fullName;
//
//       // Fetch the recipient"s FCM token from Firestore
//       const userDoc = await recipientRef.get();
//       const userData = userDoc.data();
//
//       if (userData && userData.fcmToken) {
//         const fcmToken = userData.token;
//
//         // Define the notification payload
//         const payload = {
//           notification: {
//             title: `New message from ${senderName}`,
//             body: messageText,
//             clickAction: "FLUTTER_NOTIFICATION_CLICK", // handle click actions
//           },
//           data: {
//             chatId: context.params.chatId, // Pass chat ID to open the chat
//           },
//         };
//
//         await fcm.sendToDevice(fcmToken, payload);
//         console.log("Notification sent to " + senderName);
//       } else {
//         console.log("No FCM token found for recipient " + recipientRef);
//       }
//     } catch (error) {
//       console.error("Error sending notification:", error);
//     }
//   });