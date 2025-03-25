import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:near_me/core/constants/user_constant.dart';

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;
  const AppLifecycleObserver({Key? key, required this.child}) : super(key: key);

  @override
  _AppLifecycleObserverState createState() => _AppLifecycleObserverState();

  // Expose a way to update userId dynamically
  static final ValueNotifier<String?> userIdNotifier =
      ValueNotifier<String?>(UserConstant().getUserId());

  static void setUserId(String? newUserId) {
    userIdNotifier.value = newUserId;
  }
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  final FirebaseDatabase realTimeDB = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("✅ AppLifecycleObserver added to WidgetsBinding.");

    // Listen for userId changes
    AppLifecycleObserver.userIdNotifier.addListener(() {
      _handleUserIdChange(AppLifecycleObserver.userIdNotifier.value);
    });

    // Trigger lifecycle state manually on startup
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null) {
      print("🔥 Initial lifecycle state: $state");
      didChangeAppLifecycleState(state);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppLifecycleObserver.userIdNotifier.removeListener(() {});
    super.dispose();
  }

  void _handleUserIdChange(String? userId) {
    if (userId != null) {
      print("🔄 User ID updated: $userId → Updating online status");
      _setUserOnlineStatus(userId, true);
    }
  }

  void _setUserOnlineStatus(String userId, bool isOnline) {
    final ref = realTimeDB.ref("users/$userId/status");

    ref.update({
      "online": isOnline,
      "lastSeen": isOnline
          ? ServerValue.timestamp
          : DateTime.now().millisecondsSinceEpoch,
    });

    if (isOnline) {
      ref.onDisconnect().update({
        "online": false,
        "lastSeen": ServerValue.timestamp,
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("🔥 App lifecycle changed: $state");

    final userId = AppLifecycleObserver.userIdNotifier.value;
    if (userId == null) {
      print("⚠️ User ID is null, skipping status update.");
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print("⛔ App is paused/closed → Setting offline");
      _setUserOnlineStatus(userId, false);
    } else if (state == AppLifecycleState.resumed) {
      print("✅ App resumed → Setting online");
      _setUserOnlineStatus(userId, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
