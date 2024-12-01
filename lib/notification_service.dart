import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'create_screen.dart';
import 'shared_preferences_helper.dart';
import 'vibrations.dart';

class NotificationService {
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelGroupKey: 'vibration_tests',
            channelKey: 'low',
            channelName: 'Low intensity notifications',
            channelDescription:
                'Notification channel for notifications with low intensity',
            enableVibration: false,
            importance: NotificationImportance.High),
        NotificationChannel(
            channelGroupKey: 'vibration_tests',
            channelKey: 'medium',
            channelName: 'Medium intensity notifications',
            channelDescription:
                'Notification channel for notifications with medium intensity',
            enableVibration: false,
            importance: NotificationImportance.High),
        NotificationChannel(
            channelGroupKey: 'vibration_tests',
            channelKey: 'high',
            channelName: 'High intensity notifications',
            channelDescription:
                'Notification channel for notifications with high intensity',
            enableVibration: false,
            importance: NotificationImportance.High),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'vibration_tests',
          channelGroupName: 'Vibration tests',
        ),
      ],
      debug: true,
    );
  }

  static Future<void> initializeNotificationsEventListeners() async {
    AwesomeNotifications().setListeners(
      onNotificationCreatedMethod:
          NotificationService.onNotificationCreatedMethod,
      onDismissActionReceivedMethod:
          NotificationService.onDismissActionReceivedMethod,
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );

    FirebaseMessaging.onMessage.listen(fcmHandler);
    FirebaseMessaging.onBackgroundMessage(fcmHandler);
  }

  static Future<void> fcmHandler(RemoteMessage event) async {
    String title = event.notification!.title ?? '';
    String body = event.notification!.body ?? '';
    String channelKey = event.data['vibrationLevel'];

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    var message =
        'onNotificationCreatedMethod ${receivedNotification.createdLifeCycle?.name}';
    print(message);
    print(receivedNotification.channelKey);

    await Vibrations.trigger(receivedNotification.channelKey ?? '');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    var message =
        'onActionReceivedMethod ${receivedNotification.createdLifeCycle?.name}';
    print(message);
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    var message =
        'onDismissActionReceivedMethod ${receivedNotification.createdLifeCycle?.name}';
    print(message);

    await Vibrations.trigger(
      receivedNotification.channelKey ?? '',
      false,
    );
  }

  static Future<void> createNewNotification(String channelKey) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return;

    final data = await SharedPreferencesHelper.loadNotificationData(
            notificationDataKey) ??
        defaultData;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: channelKey,
        title: data.title,
        body: data.body,
        largeIcon: data.imageURL,
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }
}
