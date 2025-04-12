const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function to send FCM Notification
exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
  const { fcmToken, title, body } = req.body;

  if (!fcmToken || !title || !body) {
    return res.status(400).send('Missing required fields: fcmToken, title, or body');
  }

  try {
    const message = {
      notification: {
        title: title,
        body: body,
      },
      token: fcmToken,  // Target the device with the fcmToken
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    res.status(200).send('Notification sent successfully');
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).send('Error sending notification');
  }
});
