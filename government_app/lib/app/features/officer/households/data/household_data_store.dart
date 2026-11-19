import '../../workers/screens/data/worker_data_store.dart';

class HouseholdDataStore {
  // ============================================================
  // IN-MEMORY STORAGE
  // ============================================================

  static final List<Map<String, dynamic>> households = [];

  static int _idCounter = 0;

  // ============================================================
  // ID GENERATION
  // ============================================================

  static String _generateId(String prefix) {
    _idCounter++;

    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_idCounter';
  }

  static String _generateHouseholdId() {
    return _generateId('HH');
  }

  static String _generateIndividualId() {
    return _generateId('IND');
  }

  // ============================================================
  // CONSTANTS
  // ============================================================

    static const List<String> consentStatuses = [
  'Pending',
  'Granted',
  'Declined',
  'Revoked',
];

  // ============================================================
  // SAFE CONVERSION
  // ============================================================

  static int _toInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<Map<String, dynamic>> _getMembers(
    Map<String, dynamic> household,
  ) {
    final members = household['members'];

    if (members is! List) return [];

    return members
        .whereType<Map>()
        .map((member) => Map<String, dynamic>.from(member))
        .toList();
  }

  // ============================================================
  // ACTIVE WORKERS
  // ============================================================

  static List<Map<String, dynamic>> get activeWorkers {
    return WorkerDataStore.workers.where((worker) {
      return worker['status'] == 'Active';
    }).toList();
  }

  // ============================================================
  // REGISTER HOUSEHOLD
  // ============================================================

  static Map<String, dynamic>? registerHousehold({
    required String householdName,
    required String address,
    required String area,
    required String headOfHousehold,
    required String phone,
    required String workerId,
    required String workerName,
  }) {
    if (householdName.trim().isEmpty ||
        address.trim().isEmpty ||
        area.trim().isEmpty ||
        headOfHousehold.trim().isEmpty ||
        phone.trim().isEmpty) {
      return null;
    }

    final workerIndex = WorkerDataStore.workers.indexWhere(
      (worker) =>
          worker['id'].toString() == workerId &&
          worker['status'] == 'Active' &&
          worker['name'].toString() == workerName,
    );

    if (workerIndex == -1) return null;

    final actualWorker = WorkerDataStore.workers[workerIndex];

    final household = <String, dynamic>{
      'id': _generateHouseholdId(),

      'householdName': householdName.trim(),
      'address': address.trim(),
      'area': area.trim(),

      'headOfHousehold': headOfHousehold.trim(),
      'phone': phone.trim(),

      'workerId': workerId,
      'workerName': actualWorker['name'],

      'members': <Map<String, dynamic>>[],
      'memberCount': 0,

      'consentStatus': 'Pending',

      'status': 'Registered',

      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    households.add(household);

    return household;
  }

  // ============================================================
  // GET ALL HOUSEHOLDS
  // ============================================================

  static List<Map<String, dynamic>> getAllHouseholds() {
    return List<Map<String, dynamic>>.from(households);
  }

  // ============================================================
  // GET HOUSEHOLD BY ID
  // ============================================================

  static Map<String, dynamic>? getHouseholdById(
    String householdId,
  ) {
    try {
      return households.firstWhere(
        (household) => household['id'].toString() == householdId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // GET HOUSEHOLDS BY WORKER
  // ============================================================

  static List<Map<String, dynamic>> getWorkerHouseholds(
    String workerId,
  ) {
    return households.where((household) {
      return household['workerId'].toString() == workerId;
    }).toList();
  }

  // ============================================================
  // REGISTER INDIVIDUAL
  // ============================================================

  static Map<String, dynamic>? registerIndividual({
    required String householdId,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String relationship,
    required String phone,
  }) {
    final household = getHouseholdById(householdId);

    if (household == null) return null;

    if (name.trim().isEmpty ||
        gender.trim().isEmpty ||
        relationship.trim().isEmpty) {
      return null;
    }

    if (dateOfBirth.isAfter(DateTime.now())) {
      return null;
    }

    // Prevent duplicate registration within the same household.
    final existingMembers = _getMembers(household);

    final duplicate = existingMembers.any((member) {
      final sameName =
          member['name'].toString().trim().toLowerCase() ==
              name.trim().toLowerCase();

      final existingDob = member['dateOfBirth'];

      final sameDob = existingDob is DateTime &&
          existingDob.year == dateOfBirth.year &&
          existingDob.month == dateOfBirth.month &&
          existingDob.day == dateOfBirth.day;

      return sameName && sameDob;
    });

    if (duplicate) return null;

    final now = DateTime.now();

    final member = <String, dynamic>{
      'id': _generateIndividualId(),

      'householdId': householdId,

      'name': name.trim(),

      'dateOfBirth': dateOfBirth,

      'age': _calculateAge(dateOfBirth),

      'gender': gender.trim(),

      'relationship': relationship.trim(),

      'phone': phone.trim(),

      // New individuals always start with Pending consent.
      'consentStatus': 'Pending',

      'consentHistory': <Map<String, dynamic>>[],

      'consentUpdatedAt': null,

      'registeredAt': now,

      'updatedAt': now,

      'screeningHistory': <Map<String, dynamic>>[],

      'aiAssessments': <Map<String, dynamic>>[],

      'referrals': <Map<String, dynamic>>[],
    };

    final members = household['members'];

    if (members is! List) {
      household['members'] = <Map<String, dynamic>>[];
    }

    (household['members'] as List).add(member);

    household['memberCount'] =
        (household['members'] as List).length;

    household['updatedAt'] = now;

    return member;
  }

  // ============================================================
  // CALCULATE AGE
  // ============================================================

  static int _calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();

    int age = today.year - dateOfBirth.year;

    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month &&
            today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  // ============================================================
  // GET HOUSEHOLD MEMBERS
  // ============================================================

  static List<Map<String, dynamic>> getHouseholdMembers(
    String householdId,
  ) {
    final household = getHouseholdById(householdId);

    if (household == null) return [];

    return _getMembers(household);
  }

  // ============================================================
  // GET INDIVIDUAL BY ID
  // ============================================================

  static Map<String, dynamic>? getIndividualById({
    required String householdId,
    required String individualId,
  }) {
    final household = getHouseholdById(householdId);

    if (household == null) return null;

    final members = household['members'];

    if (members is! List) return null;

    try {
      return (members.firstWhere(
        (member) =>
            member['id'].toString() == individualId,
      ) as Map).cast<String, dynamic>();
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // UPDATE INDIVIDUAL DETAILS
  // ============================================================

  static bool updateIndividual({
    required String householdId,
    required String individualId,
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required String relationship,
    required String phone,
  }) {
    final household = getHouseholdById(householdId);

    if (household == null) return false;

    if (name.trim().isEmpty ||
        gender.trim().isEmpty ||
        relationship.trim().isEmpty) {
      return false;
    }

    if (dateOfBirth.isAfter(DateTime.now())) {
      return false;
    }

    final members = household['members'];

    if (members is! List) return false;

    final index = members.indexWhere((member) {
      return member['id'].toString() == individualId;
    });

    if (index == -1) return false;

    final member = members[index] as Map<String, dynamic>;

    // Prevent duplicate individual records.
    final duplicate = members.any((other) {
      if (other['id'].toString() == individualId) {
        return false;
      }

      final sameName =
          other['name'].toString().trim().toLowerCase() ==
              name.trim().toLowerCase();

      final existingDob = other['dateOfBirth'];

      final sameDob = existingDob is DateTime &&
          existingDob.year == dateOfBirth.year &&
          existingDob.month == dateOfBirth.month &&
          existingDob.day == dateOfBirth.day;

      return sameName && sameDob;
    });

    if (duplicate) return false;

    member['name'] = name.trim();
    member['dateOfBirth'] = dateOfBirth;
    member['age'] = _calculateAge(dateOfBirth);
    member['gender'] = gender.trim();
    member['relationship'] = relationship.trim();
    member['phone'] = phone.trim();
    member['updatedAt'] = DateTime.now();

    household['updatedAt'] = DateTime.now();

    return true;
  }

  // ============================================================
  // UPDATE HOUSEHOLD CONSENT
  // ============================================================

  static bool updateHouseholdConsent({
    required String householdId,
    required String consentStatus,
  }) {
    final household = getHouseholdById(householdId);

    if (household == null) return false;

    if (!consentStatuses.contains(consentStatus)) {
      return false;
    }

    final now = DateTime.now();

    household['consentStatus'] = consentStatus;
    household['consentUpdatedAt'] = now;
    household['updatedAt'] = now;

    return true;
  }

  // ============================================================
  // UPDATE INDIVIDUAL CONSENT
  // ============================================================

  static bool updateIndividualConsent({
    required String householdId,
    required String individualId,
    required String consentStatus,
    String recordedBy = 'Health Officer',
    String notes = '',
    String consentMethod = 'Not specified',
    String consentFormVersion = '1.0',
    String? guardianName,
    String? guardianRelationship,
  }) {
    final household = getHouseholdById(householdId);

    if (household == null) return false;

    if (!consentStatuses.contains(consentStatus)) {
      return false;
    }

    if (recordedBy.trim().isEmpty) return false;

    final members = household['members'];

    if (members is! List) return false;

    final index = members.indexWhere((member) {
      return member['id'].toString() == individualId;
    });

    if (index == -1) return false;

    final member = members[index] as Map<String, dynamic>;

    final now = DateTime.now();

    

    if (member['consentHistory'] is! List) {
      member['consentHistory'] =
          <Map<String, dynamic>>[];
    }

    final record = <String, dynamic>{
      'id': _generateId('CONSENT'),

      'status': consentStatus,

      'recordedBy': recordedBy.trim(),

      'notes': notes.trim(),

      'consentMethod': consentMethod,

      'consentFormVersion': consentFormVersion,

      'guardianName': guardianName,

      'guardianRelationship': guardianRelationship,

      'recordedAt': now,
    };

    (member['consentHistory'] as List).add(record);

    member['consentStatus'] = consentStatus;

    member['consentUpdatedAt'] = now;

    member['updatedAt'] = now;

    household['updatedAt'] = now;

    return true;
  }

  // ============================================================
  // CHECK INDIVIDUAL SCREENING CONSENT
  // ============================================================
  // ============================================================
// UPDATE INDIVIDUAL SCREENING STATUS
// ============================================================

static bool markIndividualScreeningCompleted({
  required String householdId,
  required String individualId,
  String recordedBy = 'Health Worker',
}) {
  final household = getHouseholdById(householdId);

  if (household == null) return false;

  final members = household['members'];

  if (members is! List) return false;

  final index = members.indexWhere(
    (member) => member['id'].toString() == individualId,
  );

  if (index == -1) return false;

  final member = members[index] as Map<String, dynamic>;

  // Valid consent is mandatory.
  if (member['consentStatus'] != 'Granted') {
    return false;
  }

  final now = DateTime.now();

  // Avoid duplicate completion history.
  if (member['screeningStatus'] == 'Completed') {
    return true;
  }

  member['screeningStatus'] = 'Completed';
  member['screeningCompletedAt'] = now;
  member['screeningRecordedBy'] = recordedBy;
  member['updatedAt'] = now;

  if (member['screeningHistory'] is! List) {
    member['screeningHistory'] = <Map<String, dynamic>>[];
  }

  (member['screeningHistory'] as List).add({
    'status': 'Completed',
    'recordedBy': recordedBy,
    'completedAt': now,
  });

  household['updatedAt'] = now;

  return true;
}
  
  static bool hasScreeningConsent({
    required String householdId,
    required String individualId,
  }) {
    final member = getIndividualById(
      householdId: householdId,
      individualId: individualId,
    );

    if (member == null) return false;

    return member['consentStatus'] == 'Granted';
  }

  // ============================================================
  // GET CONSENT HISTORY
  // ============================================================

  static List<Map<String, dynamic>> getConsentHistory({
    required String householdId,
    required String individualId,
  }) {
    final member = getIndividualById(
      householdId: householdId,
      individualId: individualId,
    );

    if (member == null) return [];

    final history = member['consentHistory'];

    if (history is! List) return [];

    return history
        .whereType<Map>()
        .map((record) => Map<String, dynamic>.from(record))
        .toList();
  }

  // ============================================================
  // DASHBOARD STATISTICS
  // ============================================================

  static int get totalHouseholds => households.length;

  static int get totalIndividuals {
    return households.fold<int>(
      0,
      (total, household) =>
          total + _toInt(household['memberCount']),
    );
  }

  static int get householdsWithConsent {
    return households.where((household) {
      return household['consentStatus'] == 'Granted';
    }).length;
  }

  static int get individualsWithConsent {
    return households.fold<int>(
      0,
      (total, household) {
        return total +
            _getMembers(household)
                .where(
                  (member) =>
                      member['consentStatus'] == 'Granted',
                )
                .length;
      },
    );
  }

  static int get individualsPendingConsent {
    return households.fold<int>(
      0,
      (total, household) {
        return total +
            _getMembers(household)
                .where(
                  (member) =>
                      member['consentStatus'] == 'Pending',
                )
                .length;
      },
    );
  }

  static int get individualsDeclinedConsent {
    return households.fold<int>(
      0,
      (total, household) {
        return total +
            _getMembers(household)
                .where(
                  (member) =>
                      member['consentStatus'] == 'Declined',
                )
                .length;
      },
    );
  }
}