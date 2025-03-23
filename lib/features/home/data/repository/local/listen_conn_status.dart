import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/constants/user_status.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';

import '../../../domain/entities/connection_model.dart';

class ConnectionStatusListener {
  final FirebaseDatabase realTimeDb;
  final DatabaseHelper localDb;
  final FirebaseFirestore firestore;

  ConnectionStatusListener(
      {required this.localDb,
      required this.realTimeDb,
      required this.firestore});

  void listenToConnectionStatus() async {
    // await copyDatabaseToPublic();
    // Step 1: Get all connections from SQLite
    await syncConnectionsWithFirestore();
    List<ConnectionModel> connections = await localDb.getAllConnections();

    // Step 2: Fetch initial data from Firebase and update SQLite
    for (var connection in connections) {
      var snapshot =
          await realTimeDb.ref("users/${connection.id}/status").get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        bool isOnline = data["online"] ?? false;
        String lastSeen = data["lastSeen"] != null
            ? DateTime.fromMillisecondsSinceEpoch(data["lastSeen"])
                .toIso8601String()
            : DateTime.now().toIso8601String();

        // Update the local database with initial values
        ConnectionModel updatedConnection = connection.copyWith(
          isOnline: isOnline,
          lastSeen: lastSeen,
        );
        userStatus[connection.id] = {'online': isOnline, 'lastSeen': lastSeen};
        await localDb.updateConnection(updatedConnection);
      }

      // Step 3: Start listening for real-time updates after fetching initial data
      realTimeDb
          .ref("users/${connection.id}/status")
          .onValue
          .listen((event) async {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> data =
              event.snapshot.value as Map<dynamic, dynamic>;
          bool isOnline = data["online"] ?? false;
          String lastSeen = data["lastSeen"] != null
              ? DateTime.fromMillisecondsSinceEpoch(data["lastSeen"])
                  .toIso8601String()
              : DateTime.now().toIso8601String();

          // Update in local database
          ConnectionModel updatedConnection = connection.copyWith(
            isOnline: isOnline,
            lastSeen: lastSeen,
          );
          userStatus[connection.id] = {
            'online': isOnline,
            'lastSeen': lastSeen
          };
          await localDb.updateConnection(updatedConnection);
        }
      });
    }
  }

  Future<void> copyDatabaseToPublic() async {
    try {
      // Get the path to the database
      String dbPath = "/data/data/com.example.near_me/databases/connections.db";

      // Define the public path where we will copy the database
      String newPath = "/storage/emulated/0/Download/connections.db";

      // Copy the database file
      File(dbPath).copySync(newPath);

      print("Database copied to: $newPath");
    } catch (e) {
      print("Error copying database: $e");
    }
  }

  Future<void> syncConnectionsWithFirestore() async {
    try {
      var myId = UserConstant().getUserId();

      // Step 2: Fetch connections from Firestore
      var snapshot = await firestore
          .collection("connections")
          .where('users', arrayContains: myId)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String? userId;
        for (var uid in data['users']) {
          if (uid != myId) {
            userId = uid;
          }
          if (userId == null) {
            continue;
          }
        }

        // Get user details from Firestore
        var userSnapshot =
            await firestore.collection("users").doc(userId).get();
        if (!userSnapshot.exists) continue;

        var userData = userSnapshot.data()!;
        String name = userData["name"] ?? "";
        String profilePic = userData["photoUrl"] ?? "";
        // Check if user exists in local DB
        ConnectionModel? existingConnection =
            await localDb.getConnectionById(userId!);

        if (existingConnection != null) {
          // Update existing record in SQLite
          ConnectionModel updatedConnection = existingConnection.copyWith(
            name: name,
            profilePic: profilePic,
          );
          await localDb.updateConnection(updatedConnection);
        } else {
          // Insert new connection into SQLite
          ConnectionModel newConnection = ConnectionModel(
            id: userId,
            name: name,
            profilePic: profilePic,
            gender: userData["gender"] ?? "Unknown",
            isOnline: false, // Default false
            lastSeen: DateTime.now().toIso8601String(), // Default
          );
          await localDb.insertConnection(newConnection);
        }
      }
      print("✅ SQLite DB updated with Firestore connection details!");
    } catch (e) {
      print("❌ Error syncing connections: $e");
    }
  }
}
