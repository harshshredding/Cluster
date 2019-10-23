import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();
const db = admin.firestore();

export const sendToDevice = functions.firestore
  .document('kingdoms/{kingdomId}/chats/{chatId}/chat_room/{messageId}')
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    if (message != null) {
      // get reference to chat
      const chatDocumentReference = await snapshot.ref.parent.parent;
      if (chatDocumentReference != null) {
        const chat = await chatDocumentReference.get();
        const proposalID = chat.get("proposal_id");

        const proposalSnap = await db
        .collection('kingdoms')
        .doc(context.params.kingdomId)
        .collection('proposals')
        .doc(proposalID).get();

        const proposalTitle = proposalSnap.get("title");

        const querySnapshot = await db
        .collection('kingdoms')
        .doc(context.params.kingdomId)
        .collection('users')
        .doc(message.receiver)
        .collection('tokens')
        .get();

        const tokens = querySnapshot.docs.map(snap => snap.id);
        const payload: admin.messaging.MessagingPayload = {
          notification: {
            title: proposalTitle,
            body: message.text,
            click_action: 'FLUTTER_NOTIFICATION_CLICK'
          }
        };
        return fcm.sendToDevice(tokens, payload);
      } else {
        console.log("nooo!!!!");
      }
    }
    return null;
  });

