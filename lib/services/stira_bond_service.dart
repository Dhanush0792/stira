import "dart:math";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class StiraBondService {
  final _db = FirebaseFirestore.instance;

  /// Generate a unique 6-digit Bond Code and save it to the user document.
  Future<String> generateBondCode(String userId) async {
    final code = (100000 + Random().nextInt(900000)).toString();
    // Using set with merge: true to ensure document exists if it doesn't already
    await _db.collection("users").doc(userId).set({
      "bond_code": code,
      "bond_partner_uid": "",
      "bond_share_level": "streak_only",
    }, SetOptions(merge: true));
    return code;
  }

  /// Phase 1: Create a Request document so the Host can see us.
  Future<BondResult> sendConnectionRequest({
    required String senderUid,
    required String senderName,
    required String code,
    required String shareLevel,
  }) async {
    // 1. Find host by bond_code
    final query = await _db
        .collection("users")
        .where("bond_code", isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return BondResult.failure("Bond code not found.");
    }

    final hostDoc = query.docs.first;
    final hostUid = hostDoc.id;

    if (hostUid == senderUid) {
      return BondResult.failure("You cannot bond with yourself.");
    }

    // 2. Write to public requests collection
    // Security rules must allow CREATE for auth users.
    await _db.collection("bond_requests").doc(code).set({
      "host_uid": hostUid,
      "guest_uid": senderUid,
      "guest_name": senderName,
      "share_level": shareLevel,
      "timestamp": FieldValue.serverTimestamp(),
    });

    return BondResult.success(hostDoc.data()["name"] ?? "Host");
  }

  /// Phase 2: Host accepts the request (Only Host can do this).
  Future<void> acceptBondRequest(String code, String myUid) async {
    final doc = await _db.collection("bond_requests").doc(code).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final guestUid = data["guest_uid"] as String;
    final shareLevel = data["share_level"] as String;

    // Update MY document
    await _db.collection("users").doc(myUid).update({
      "bond_partner_uid": guestUid,
      "bond_share_level": shareLevel,
      "bond_code": "", // Clear code
    });

    // We do NOT update the guest's document (Permission Denied).
    // The guest will listen to our document and update themselves.
    
    // Delete the request
    await _db.collection("bond_requests").doc(code).delete();
  }

  /// Listen for incoming requests to my Bond Code.
  Stream<Map<String, dynamic>?> listenForIncomingRequest(String code) {
    return _db
        .collection("bond_requests")
        .doc(code)
        .snapshots()
        .map((snap) => snap.data());
  }

  /// Update share level (what the partner can see).
  Future<void> updateShareLevel(String userId, String level) async {
    await _db.collection("users").doc(userId).update({
      "bond_share_level": level,
    });
  }

  /// End the bond (either person can end it).
  Future<void> endBond(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    final data = doc.data();
    if (data == null) return;
    
    final partnerUid = data["bond_partner_uid"] as String?;

    final batch = _db.batch();
    batch.update(_db.collection("users").doc(userId), {
      "bond_partner_uid": "",
      "bond_code": "",
    });

    if (partnerUid != null && partnerUid.isNotEmpty) {
      batch.update(_db.collection("users").doc(partnerUid), {
        "bond_partner_uid": "",
      });
    }

    await batch.commit();
  }

  /// Phase 3: Guest (User B) detects Host (User A) has accepted.
  /// This must be called from the Guest device after sendConnectionRequest.
  Future<void> completeBondFromGuest({
    required String hostUid,
    required String guestUid,
    required String shareLevel,
  }) async {
    // Update MY document (User B)
    await _db.collection("users").doc(guestUid).update({
      "bond_partner_uid": hostUid,
      "bond_share_level": shareLevel,
      "bond_code": "", // Clear my code
    });
  }

  /// Stream partner data for real-time Bond Mode display.
  Stream<Map<String, dynamic>?> partnerDataStream(String partnerUid) {
    return _db
        .collection("users")
        .doc(partnerUid)
        .snapshots()
        .map((snap) => snap.data());
  }
}

class BondResult {
  final bool   success;
  final String partnerName;
  final String errorMessage;

  const BondResult._({required this.success, this.partnerName = "", this.errorMessage = ""});

  factory BondResult.success(String name) => BondResult._(success: true, partnerName: name);
  factory BondResult.failure(String msg)  => BondResult._(success: false, errorMessage: msg);
}

final bondStatusProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});

final partnerDataProvider = StreamProvider.family<Map<String, dynamic>?, String>((ref, partnerUid) {
  return StiraBondService().partnerDataStream(partnerUid);
});

/// Watches for any requests I've sent that are still pending.
final pendingSentRequestProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection("bond_requests")
      .where("guest_uid", isEqualTo: user.uid)
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data());
});
