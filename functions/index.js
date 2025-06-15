const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.checkEnergyUsage = functions.database.ref("/users/{userId}/energy")
    .onUpdate(async (change, context) => {
      const userId = context.params.userId;
      const newEnergyReading = change.after.val();

      if (newEnergyReading == null) {
        console.log("No energy data.");
        return null;
      }

      // 1. Get user's monthly limit from Firestore
      const settingsRef = db.collection("user_settings").doc(userId);
      const settingsDoc = await settingsRef.get();

      if (!settingsDoc.exists) {
        console.log(`No settings found for user ${userId}`);
        return null;
      }

      const monthlyLimit = settingsDoc.data().monthly_limit;
      if (!monthlyLimit || monthlyLimit <= 0) {
        console.log(`No valid limit for user ${userId}`);
        return null;
      }

      // 2. Check if usage exceeds thresholds (e.g., 80% and 100%)
      const usagePercent = (newEnergyReading / monthlyLimit) * 100;
      let notificationTitle = null;
      let notificationBody = null;

      // Check for 80% threshold
      if (usagePercent >= 80 && usagePercent < 100) {
        notificationTitle = "High Energy Alert";
        notificationBody = `You have used ${usagePercent.toFixed(0)}% ` +
                           "of your monthly energy limit.";
      } else if (usagePercent >= 100) {
        notificationTitle = "Energy Limit Reached";
        notificationBody = "You have reached your monthly energy limit.";
      }

      if (!notificationTitle) {
        console.log(`Usage (${usagePercent.toFixed(0)}%) is not at a ` +
                    "notification threshold.");
        return null;
      }

      // 3. Get user's FCM tokens
      const tokensSnapshot = await db.collection("users")
          .doc(userId).collection("tokens").get();

      if (tokensSnapshot.empty) {
        console.log(`No FCM tokens for user ${userId}`);
        return null;
      }

      const tokens = tokensSnapshot.docs.map((doc) => doc.id);

      // 4. Send notification
      const payload = {
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          userId: userId,
          energy: newEnergyReading.toString(),
        },
      };

      console.log(`Sending notification to user ${userId}`);
      return admin.messaging().sendToDevice(tokens, payload);
    });
    