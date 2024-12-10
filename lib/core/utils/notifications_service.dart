/* import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsehub/core/di/dependancy_injection.dart';
import 'package:pulsehub/core/utils/store_manager.dart';
import 'package:pulsehub/features/notifications/presentaion/widgets/order_card.dart';
import 'package:pulsehub/features/notifications/view_model/cubit/noti_cubit.dart';
import 'package:pulsehub/features/past/presentaion/screens/view_order_screen.dart';
import 'package:pulsehub/features/past/presentaion/widgets/select_time.dart';
import 'package:pulsehub/features/past/view_model/cubit/search/search_orders_cubit.dart';
import 'package:pulsehub/my_app.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_notification_app_icon',
      [
        NotificationChannel(
          channelGroupKey: 'new_order_channel',
          channelKey: 'new_order_channel',
          channelName: 'New Order Notifications',
          channelDescription: 'Notification for new orders',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'new_order_channel',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    final payload = receivedNotification.payload ?? {};

    // If the payload contains "navigate" as "false", show the notification but dismiss it after 1 second
    if (payload["navigate"] == "false") {
      MyApp.navigatorKey.currentState?.pop();
      // Show the notification (it will be shown but dismissed automatically)
      int? notificationId = receivedNotification.id;

      // Optionally handle any logic related to accepting the order
      int orderid = int.parse(payload['orderId']!);

      if (StoreManager().store!.showTimeOnOrderAccept) {
        showTimeSelectionDialog(MyApp.navigatorKey.currentContext!, orderid);
      } else {
        BlocProvider.of<NotiCubit>(MyApp.navigatorKey.currentContext!)
            .acceptOrder(orderid, true, false, false);
      }

      BlocProvider.of<NotiCubit>(MyApp.navigatorKey.currentContext!)
          .refreshOrders();

      // Automatically dismiss the notification after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        AwesomeNotifications().dismiss(notificationId!);
      });

      return; // Return early since we don't want to navigate or keep the notification up
    }

    // If "navigate" is true, proceed with showing the notification and navigation
    if (payload["navigate"] == "true") {
      getIt<SearchOrdersCubit>().searchSingleOrder(payload['orderId']!);
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ViewOrderScreen(
            orderType: OrderType.newOrder,
            isFromNoti: true,
            isNoti: true,
            orderId: payload['orderId'],
          ),
        ),
      );
    }
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};

    if (payload["navigate"] == "true") {
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ViewOrderScreen(
            orderType: OrderType.newOrder,
            isFromNoti: true,
            orderId: payload['orderId'],
          ),
        ),
      );
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'new_order_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}

void showTimeSelectionDialog(BuildContext context, int orderId) {
  showDialog(
    barrierDismissible:
        false, // Prevents closing the dialog by tapping outside of it
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async =>
            false, // Prevents closing the dialog by pressing the back button
        child: TimeSelectionDialog(
          selectedTime: '15 min', // Default selected time
          isCustomTime: true, // Default custom time status
          onTimeSelected: (selectedTime, isCustom) {
            // Call acceptOrder with the selected time after the dialog closes
            context.read<NotiCubit>().acceptOrder(
                  orderId,
                  true, // IsAccept
                  false, // IsSelf
                  false, // Another flag
                  selectedTime, // Time in minutes selected by the user
                  isCustom, // Whether a custom time was selected
                );

            // Close the dialog after selection
            Navigator.of(context).pop();
          },
        ),
      );
    },
  );
}
 */