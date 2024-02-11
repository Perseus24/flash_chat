

import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/main.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationApp{

  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationsSettings = new InitializationSettings(android: androidInitialize);

    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showNotifications({var id = 0, required String title, required String body, var payload,
    required FlutterLocalNotificationsPlugin fln}) async{

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'meh',
        'heh',

        playSound: true,
      importance: Importance.max,
      priority: Priority.high
    );

    var noti = NotificationDetails(android:  androidNotificationDetails);

    await fln.show(id, title, body, noti);

  }

  static void configureFirebaseMessaging({required String title, required String body, var payload,
      required FlutterLocalNotificationsPlugin fln}){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.notification!=null){
        showNotifications(title: 'test', body: 'outside', fln: fln);
      }
    });
  }

  //creates an instance of Firebase Messaging

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async{
    //request permission
    await _firebaseMessaging.requestPermission();
    final token = await _firebaseMessaging.getToken();

    //get token
    print(token);
    initPushNotifications();
  }

  //handle messages
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    print('hi');
    navigatorKey.currentState?.pushNamed(ChatScreen.id);
  }

  Future initPushNotifications() async{

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  static Future<void> sendNotification() async {
    // Construct message payload
    var payload = {
      'notification': {
        'title': 'Your notification title',
        'body': 'Your notification body',
      },
      'to': 'fH2PyNvhTAWqYeXPs3qvsm:APA91bHRo5hyYKcIlDpIrlSTRRQl1HONVu83htH61Ro4CSHRjBtiLg5cYT_EUAnvHkVBLWJC4-6Gdl6EW4WrO_GFuSz1ilhqwshF_rFANvSi7KVqbh7dXg8oNLOPHM0CAdv0m2zKwYcw',
    };

    // Send HTTP POST request to FCM endpoint
    var response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=60905720073',
      },
      body: jsonEncode(payload),
    );

    // Check response status
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.reasonPhrase}');
    }
  }
}

class ChatNotification{

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }
  static Future<void> initializeNotification() async{
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic Notification',
          channelDescription: 'Test notification',
          defaultColor: Colors.white30,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1'
        )
      ],
      debug: true
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async{
        if(!isAllowed){
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      }
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod
    );
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async{
    debugPrint('NotificationCreated!');
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async{
    debugPrint('NotificationDisplayed!');
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async{
    debugPrint('DismissAction!');
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async{
    final payload = receivedAction.payload ?? {};
    if(payload['navigate'] == 'true'){
      FlashChat.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(),
        )
      );
    }
  }

  static Future<void> showNotification({required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval
    }) async{
      assert(!scheduled || (scheduled && interval!=null));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture
        ),
        actionButtons: actionButtons,
        schedule: scheduled?NotificationInterval(
          interval: interval,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
        ) : null,
      );
  }


}

class NewNotif {
  // Initialize Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Awesome Notifications
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  void initializeNotifications() {
    // Initialize Awesome Notifications settings
    _awesomeNotifications.initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
      ],
    );
  }

  // Method to handle incoming FCM messages when the app is in the background
  Future<void> setBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler function
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
    showNotification(message.data['title'], message.data['body']);
  }

  // Method to handle incoming FCM messages when the app is in the foreground
  void setForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Handling a foreground message ${message.messageId}');
      showNotification(message.notification?.title, message.notification?.body);
    });
  }

  // Method to show the notification using Awesome Notifications
  void showNotification(String? title, String? body) {
    _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: title ?? 'Notification',
        body: body ?? 'New message',

      ),
    );
  }

  // Method to send a test notification
  void sendNotification() {
    showNotification('Test Notification', 'This is a test notification');
  }
}