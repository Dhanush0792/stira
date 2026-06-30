import "package:cloud_firestore/cloud_firestore.dart";

class StiraJournalService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveJournalEntry({
    required String userId,
    required String content,
    required String category, // exercise/connection/achievement/creativity/nature/food/rest
    bool isShared = false,
  }) async {
    await _db
        .collection("users")
        .doc(userId)
        .collection("dopamine_journal")
        .add({
      "date":      FieldValue.serverTimestamp(),
      "content":   content,
      "category":  category,
      "is_shared": isShared,
    });
  }

  Future<List<Map<String, dynamic>>> getEntriesForMonth(
    String userId, DateTime month,
  ) async {
    final start = DateTime(month.year, month.month, 1);
    final end   = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final snap  = await _db
        .collection("users")
        .doc(userId)
        .collection("dopamine_journal")
        .where("date", isGreaterThanOrEqualTo: start)
        .where("date", isLessThanOrEqualTo: end)
        .orderBy("date")
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }
}
