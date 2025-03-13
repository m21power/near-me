import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:near_me/core/constants/user_constant.dart';

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({Key? key, required this.child}) : super(key: key);

  @override
  _AppLifecycleObserverState createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  final FirebaseDatabase realTimeDB = FirebaseDatabase.instance;
  final String? userId = UserConstant().getUserId();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserOnlineStatus(true); // Set user online when app starts
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setUserOnlineStatus(bool isOnline) {
    if (userId != null) {
      realTimeDB.ref("users/$userId/status").set({
        "online": isOnline,
        "lastSeen": isOnline
            ? ServerValue.timestamp
            : DateTime.now().millisecondsSinceEpoch,
      });

      if (isOnline) {
        // Ensure user goes offline when app closes unexpectedly
        realTimeDB.ref("users/$userId/status/online").onDisconnect().set(false);
        realTimeDB
            .ref("users/$userId/status/lastSeen")
            .onDisconnect()
            .set(ServerValue.timestamp);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (userId == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // User closed or switched app → Set offline
      _setUserOnlineStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      // User opened app again → Set online
      _setUserOnlineStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
