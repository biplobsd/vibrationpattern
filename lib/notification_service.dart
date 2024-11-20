import 'package:awesome_notifications/awesome_notifications.dart';

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
        ),
        NotificationChannel(
          channelGroupKey: 'vibration_tests',
          channelKey: 'medium',
          channelName: 'Medium intensity notifications',
          channelDescription:
              'Notification channel for notifications with medium intensity',
          enableVibration: false,
        ),
        NotificationChannel(
          channelGroupKey: 'vibration_tests',
          channelKey: 'high',
          channelName: 'High intensity notifications',
          channelDescription:
              'Notification channel for notifications with high intensity',
          enableVibration: false,
        ),
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

  static Future<void> createNewNotification(
      [String channelKey = 'alerts']) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: channelKey,
        title: 'Huston! The eagle has landed!',
        body:
            "A small step for a man, but a giant leap to Flutter's community!",
      ),
    );
  }
}