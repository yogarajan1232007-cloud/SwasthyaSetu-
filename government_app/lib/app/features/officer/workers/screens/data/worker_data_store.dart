class WorkerDataStore {
  static final List<Map<String, dynamic>> workers = [
    {
      'name': 'S. Kavitha',
      'initials': 'SK',
      'id': 'HW-2048',
      'area': 'Ukkadam North',
      'status': 'Active',
      'assigned': 32,
      'completed': 24,
      'pending': 8,
      'visits': 42,
    },
    {
      'name': 'M. Arul',
      'initials': 'MA',
      'id': 'HW-1984',
      'area': 'Town Hall Central',
      'status': 'Active',
      'assigned': 29,
      'completed': 21,
      'pending': 8,
      'visits': 37,
    },
    {
      'name': 'J. Fathima',
      'initials': 'JF',
      'id': 'HW-2116',
      'area': 'RS Puram West',
      'status': 'Active',
      'assigned': 26,
      'completed': 18,
      'pending': 8,
      'visits': 32,
    },
    {
      'name': 'P. Dinesh',
      'initials': 'PD',
      'id': 'HW-1842',
      'area': 'Gandhipuram',
      'status': 'Inactive',
      'assigned': 23,
      'completed': 15,
      'pending': 8,
      'visits': 28,
    },
  ];

  static int getInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int performance(Map<String, dynamic> worker) {
    final assigned = getInt(worker['assigned']);
    final completed = getInt(worker['completed']);

    if (assigned == 0) return 0;

    return ((completed / assigned) * 100).round();
  }

  static Map<String, dynamic> prepareWorker(
    Map<String, dynamic> data,
  ) {
    final name = (data['name'] ??
            data['fullName'] ??
            data['workerName'] ??
            'New Worker')
        .toString();

    final assigned = getInt(data['assigned']);
    final completed = getInt(data['completed']);

    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return {
      'name': name,
      'initials': data['initials'] ?? initials,
      'id': data['id'] ??
          data['employeeId'] ??
          'HW-${DateTime.now().millisecondsSinceEpoch}',
      'area': data['area'] ?? 'Unassigned',
      'status': data['status'] ?? 'Active',
      'assigned': assigned,
      'completed': completed,
      'pending': assigned > completed ? assigned - completed : 0,
      'visits': getInt(data['visits']),
    };
  }

  static void addWorker(Map<String, dynamic> data) {
    final newWorker = prepareWorker(data);

    final exists = workers.any(
      (worker) => worker['id'] == newWorker['id'],
    );

    if (!exists) {
      workers.add(newWorker);
    }
  }
}