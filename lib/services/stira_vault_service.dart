import "package:cloud_firestore/cloud_firestore.dart";

class StiraVaultService {
  final _db = FirebaseFirestore.instance;

  /// Save a new vault letter.
  Future<void> saveVaultLetter({
    required String userId,
    required String content,
    required String emotionalTag, // strong/calm/hopeful/determined
  }) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("vault_letters")
        .add({
      "created_at":   FieldValue.serverTimestamp(),
      "content":      content,
      "emotional_tag": emotionalTag,
      "read_count":   0,
      "last_read_at": null,
    });
  }

  /// Fetch all vault letters for archive view.
  Stream<QuerySnapshot> vaultLettersStream(String userId) {
    return _db
        .collection("users")
        .doc(userId)
        .collection("vault_letters")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  /// Fetch most recent letter for auto-surface on high intensity.
  Future<Map<String, dynamic>?> getMostRecentLetter(String userId) async {
    final snap = await _db
        .collection("users")
        .doc(userId)
        .collection("vault_letters")
        .orderBy("created_at", descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    await snap.docs.first.reference.update({
      "read_count":   FieldValue.increment(1),
      "last_read_at": FieldValue.serverTimestamp(),
    });

    return snap.docs.first.data();
  }
}
