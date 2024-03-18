import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;




class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  void initializeNotifications() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification() async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "channelId",
      "channelName",
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      "title",
      "body",
      notificationDetails,
    );
  }





  void scheduleNotifications(List<DocumentSnapshot> foodItems) {
    for (var foodItem in foodItems) {
      DateTime expiryDate =
          (foodItem['expiryDate'] as Timestamp).toDate();


          print("////////////////////////////////////////////////////////////////////////////////");

      // Check if the expiry date is approaching (within 24 hours)
      if (expiryDate.isAfter(DateTime.now()) &&
          expiryDate.isBefore(DateTime.now().add(Duration(days: 1)))) {
        // If the expiry date is approaching, schedule a notification
        scheduleNotification(expiryDate);
      }
    }
  }

Future<void> scheduleNotification(DateTime expiryDate, ) async {
  // Convert DateTime to TZDateTime
  tz.TZDateTime scheduledDate = tz.TZDateTime.from(expiryDate, tz.local);

  // Define notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "channelId",
      "channelName",
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Schedule the notification
  await _flutterLocalNotificationsPlugin.zonedSchedule(

    1,
    'Food Expiry Reminder',
    'One of your food items is expiring soon. Check it out!',
    scheduledDate.subtract(Duration(minutes: 30)), // Notify 60 minutes before expiry
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.alarmClock,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}



}


// ArgumentError (Invalid argument (scheduledDate): Must be a date in the future: Instance of 'TZDateTime')