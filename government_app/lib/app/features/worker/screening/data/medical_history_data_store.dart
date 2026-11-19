class MedicalHistoryDataStore {
  static final Map<String, Map<String, dynamic>> _records = {};

  static void save({
    required String individualId,
    required Map<String, dynamic> data,
  }) {
    _records[individualId] = {
      ...data,
      'individualId': individualId,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic>? getByIndividualId(
    String individualId,
  ) {
    final record = _records[individualId];

    return record == null ? null : Map<String, dynamic>.from(record);
  }

  static bool hasRecord(String individualId) {
    return _records.containsKey(individualId);
  }
}