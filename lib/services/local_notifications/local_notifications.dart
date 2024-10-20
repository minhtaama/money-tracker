import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// https://pub.dev/packages/flutter_local_notifications
class LocalNotificationsSingleton {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // icon name is the file located in android/app/src/main/res/drawable
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('status_bar_icon');

    // For iOS, permission should be called at the appropriate point in the application
    final DarwinInitializationSettings initSettingsDarwin = DarwinInitializationSettings(
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              'id_3',
              'Action 3',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        )
      ],
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );
  }

  // By design, iOS applications do not display notifications while the app is in the foreground unless configured to do so.
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title ?? ''),
    //     content: Text(body ?? ''),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => SecondScreen(payload),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse notificationResponse) {
    // handle action
  }

  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    // final String? payload = notificationResponse.payload;
    // if (notificationResponse.payload != null) {
    //   debugPrint('notification payload: $payload');
    // }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  // For android
  Future<void> showNotificationWithActions() async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      '...',
      '...',
      channelDescription: '...',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('id_1', 'Action 1'),
        AndroidNotificationAction('id_2', 'Action 2'),
        AndroidNotificationAction('id_3', 'Action 3'),
      ],
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _localNotificationsPlugin.show(0, '...', '...', notificationDetails);
  }
}

/// Override this provider in `ProviderScope` value with an instance
/// of `LocalNotificationsSingleton` to be able to call function `init()` first.
final localNotificationsSingletonProvider = Provider<LocalNotificationsSingleton>((ref) {
  throw UnimplementedError();
});

/// Use this provider to get [LocalNotificationsSingleton._localNotificationsPlugin] instance in widgets
final localNotificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  final localNotificationsSingleton = ref.watch(localNotificationsSingletonProvider);
  return localNotificationsSingleton._localNotificationsPlugin;
});
