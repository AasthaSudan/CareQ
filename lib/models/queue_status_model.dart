class QueueStatusModel {
  String patientId;
  String queuePosition;  // Position in the queue
  String estimatedWaitTime;  // Estimated time remaining in the queue
  String priorityLevel;  // Priority level (e.g., red, yellow, green)

  QueueStatusModel({
    required this.patientId,
    required this.queuePosition,
    required this.estimatedWaitTime,
    required this.priorityLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'queuePosition': queuePosition,
      'estimatedWaitTime': estimatedWaitTime,
      'priorityLevel': priorityLevel,
    };
  }

  factory QueueStatusModel.fromMap(Map<String, dynamic> map) {
    return QueueStatusModel(
      patientId: map['patientId'],
      queuePosition: map['queuePosition'],
      estimatedWaitTime: map['estimatedWaitTime'],
      priorityLevel: map['priorityLevel'],
    );
  }
}
