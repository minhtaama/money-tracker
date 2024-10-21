import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// https://pub.dev/packages/flutter_local_notifications
class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void init() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    // icon name is the file located in android/app/src/main/res/drawable
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('status_bar_icon');

    // For iOS, permission should be called at the appropriate point in the application
    final DarwinInitializationSettings initDarwin = DarwinInitializationSettings(
      notificationCategories: CustomNotificationDetails._iOSCategories,
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: _onDidReceiveForegroundIOSNotification,
    );

    final InitializationSettings settings = InitializationSettings(
      android: initAndroid,
      iOS: initDarwin,
    );

    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _notificationTap,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );
  }

  // By design, iOS applications do not display notifications while the app is in the foreground unless configured to do so.
  void _onDidReceiveForegroundIOSNotification(int id, String? title, String? body, String? payload) async {
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

  // When user tap the notification when the app is not running at all
  @pragma('vm:entry-point')
  static void _notificationTapBackground(NotificationResponse notificationResponse) {
    print('User tapped notification 2. Payload: ${notificationResponse.payload}, ${notificationResponse.actionId}');
  }

  // When user tap the notification
  void _notificationTap(NotificationResponse notificationResponse) async {
    print('User tapped notification. Payload: ${notificationResponse.payload}');
  }

  // For android
  Future<void> showNotificationWithActions() async {
    await _localNotificationsPlugin.show(
      0,
      'Test notification',
      'This is a test notification',
      CustomNotificationDetails.upcomingTransaction.value,
      payload: 'This is a test payload',
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledNotificationDateTime,
    required CustomNotificationDetails details,
    required String payload,
  }) async {
    await _localNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      title,
      body,
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
      details.value,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // This line ensures the notification repeats daily
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
    );
  }
}

enum CustomNotificationDetails {
  dailyReminder(
    NotificationDetails(
      android: AndroidNotificationDetails(
        _NotificationGroupID.dailyReminder,
        'Daily Reminder',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: _NotificationGroupID.dailyReminder,
        threadIdentifier: _NotificationGroupID.dailyReminder,
      ),
    ),
  ),
  upcomingTransaction(
    NotificationDetails(
      android: AndroidNotificationDetails(
        _NotificationGroupID.upcomingTransaction,
        'Upcoming Transaction',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction(
            _ActionGroupID.addUpcomingTransaction,
            'Add',
            showsUserInterface: false,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: _NotificationGroupID.upcomingTransaction,
        threadIdentifier: _NotificationGroupID.upcomingTransaction,
      ),
    ),
  ),
  ;

  // Category is used in iOS to implement action buttons. This must be create at init.
  static List<DarwinNotificationCategory> _iOSCategories = [
    const DarwinNotificationCategory(
      _NotificationGroupID.dailyReminder,
    ),
    DarwinNotificationCategory(
      _NotificationGroupID.upcomingTransaction,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          _ActionGroupID.addUpcomingTransaction,
          'Add',
          options: {
            DarwinNotificationActionOption.destructive,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  final NotificationDetails value;
  const CustomNotificationDetails(this.value);
}

class _NotificationGroupID {
  static const String dailyReminder = '0';
  static const String upcomingTransaction = '1';
}

class _ActionGroupID {
  static const String addUpcomingTransaction = '0';
}

/// Override this provider in `ProviderScope` value with an instance
/// of `LocalNotificationsSingleton` to be able to call function `init()` first.
final localNotificationsServiceProvider = Provider<LocalNotificationsService>((ref) {
  throw UnimplementedError();
});

// /// Use this provider to get [LocalNotificationsSingleton._localNotificationsPlugin] instance in widgets
// final localNotificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
//   final localNotificationsSingleton = ref.watch(localNotificationsSingletonProvider);
//   return localNotificationsSingleton._localNotificationsPlugin;
// });
