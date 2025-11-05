class TriageStats {
  final int totalPatients;
  final int criticalCount;
  final int urgentCount;
  final int stableCount;
  final double averageWaitTime;
  final int availableRooms;
  final int occupiedRooms;

  TriageStats({
    required this.totalPatients,
    required this.criticalCount,
    required this.urgentCount,
    required this.stableCount,
    required this.averageWaitTime,
    required this.availableRooms,
    required this.occupiedRooms,
  });
}