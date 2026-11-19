class MeasurementDataStore {
  static final Map<String, Map<String, dynamic>> _records = {};

  // Save or update measurements for an individual.
  static void save({
    required String individualId,
    required String householdId,
    required Map<String, dynamic> measurements,
  }) {
    final existing = _records[individualId] ?? {};

    _records[individualId] = {
      ...existing,
      ...measurements,
      'individualId': individualId,
      'householdId': householdId,
      'recordedAt': DateTime.now().toIso8601String(),
    };
  }

  // Retrieve an individual's complete record.
  static Map<String, dynamic>? getByIndividualId(
    String individualId,
  ) {
    final record = _records[individualId];

    return record == null
        ? null
        : Map<String, dynamic>.from(record);
  }

  // Check whether a record exists.
  static bool hasRecord(String individualId) {
    return _records.containsKey(individualId);
  }

  // Save additional test measurements.
  static void saveAdditionalTests({
    required String individualId,
    required Map<String, dynamic> tests,
  }) {
    final record = _records[individualId] ?? {};

    record['additionalTests'] = {
      ...?record['additionalTests'] as Map<String, dynamic>?,
      ...tests,
    };

    record['additionalTestsRecordedAt'] =
        DateTime.now().toIso8601String();

    _records[individualId] = record;
  }

  // Add a medical document's metadata.
  static void addMedicalDocument({
    required String individualId,
    required String householdId,
    required Map<String, dynamic> document,
  }) {
    final record = _records[individualId] ?? {
      'individualId': individualId,
      'householdId': householdId,
      'recordedAt': DateTime.now().toIso8601String(),
    };

    final documents = List<Map<String, dynamic>>.from(
      record['medicalDocuments'] ?? [],
    );

    documents.add({
      ...document,
      'documentId': DateTime.now().microsecondsSinceEpoch.toString(),
      'uploadedAt': DateTime.now().toIso8601String(),
    });

    record['medicalDocuments'] = documents;
    _records[individualId] = record;
  }

  // Retrieve uploaded document metadata.
  static List<Map<String, dynamic>> getMedicalDocuments(
    String individualId,
  ) {
    final record = _records[individualId];

    if (record == null) return [];

    return List<Map<String, dynamic>>.from(
      record['medicalDocuments'] ?? [],
    );
  }

  // Remove a document using its ID.
  static void removeMedicalDocument({
    required String individualId,
    required String documentId,
  }) {
    final record = _records[individualId];

    if (record == null) return;

    final documents = List<Map<String, dynamic>>.from(
      record['medicalDocuments'] ?? [],
    );

    documents.removeWhere(
      (document) => document['documentId'] == documentId,
    );

    record['medicalDocuments'] = documents;
    _records[individualId] = record;
  }
}