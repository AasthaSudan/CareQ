class RoomModel {
  final String id;
  final String number;
  final String floor;
  final String status; // Available, Occupied, Cleaning
  final String? patientId;

  RoomModel({required this.id, required this.number, required this.floor, required this.status, this.patientId});

  Map<String, dynamic> toMap() => {'number': number, 'floor': floor, 'status': status, 'patientId': patientId};

  factory RoomModel.fromMap(Map<String, dynamic> m, String id) {
    return RoomModel(id: id, number: m['number'] ?? '', floor: m['floor'] ?? '1', status: m['status'] ?? 'Available', patientId: m['patientId']);
  }
}
