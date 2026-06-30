import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'stira_bond_service.dart';

/// StiraBondGuardian — A background listener for Guest users.
/// It waits for the Host to accept the bond request and then
/// automatically finalizes the connection on the Guest's document.
class StiraBondGuardian {
  static final StiraBondGuardian _instance = StiraBondGuardian._internal();
  factory StiraBondGuardian() => _instance;
  StiraBondGuardian._internal();

  StreamSubscription? _requestSub;
  StreamSubscription? _hostSub;
  String? _currentRequestId;

  void start() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Listen for requests I have sent (Guest side)
    _requestSub?.cancel();
    _requestSub = FirebaseFirestore.instance
        .collection("bond_requests")
        .where("guest_uid", isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .listen((snap) {
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        final hostUid = data["host_uid"] as String;
        final shareLevel = data["share_level"] as String;
        _currentRequestId = snap.docs.first.id;
        
        // 2. Start listening to the Host's doc to see when they accept
        _listenToHost(hostUid, user.uid, shareLevel);
      } else {
        _hostSub?.cancel();
        _currentRequestId = null;
      }
    });
  }

  void _listenToHost(String hostUid, String myUid, String shareLevel) {
    _hostSub?.cancel();
    _hostSub = FirebaseFirestore.instance
        .collection("users")
        .doc(hostUid)
        .snapshots()
        .listen((snap) async {
      if (snap.exists) {
        final data = snap.data()!;
        if (data["bond_partner_uid"] == myUid) {
          // Success! Host accepted.
          // Now update MY document to finalize.
          await StiraBondService().completeBondFromGuest(
            hostUid: hostUid,
            guestUid: myUid,
            shareLevel: shareLevel,
          );
          
          // Cleanup: stop listening to host
          _hostSub?.cancel();
        }
      }
    });
  }

  void stop() {
    _requestSub?.cancel();
    _hostSub?.cancel();
  }
}
