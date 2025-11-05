class RoomModel {
  final String id;
  final String number;
  final String floor;
  final String status;
  final String? patientId;
  final String? patientName;
  final DateTime? assignedTime;
  final String? type;

  RoomModel({
    required this.id,
    required this.number,
    required this.floor,
    required this.status,
    this.patientId,
    this.patientName,
    this.assignedTime,
    this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'floor': floor,
    'status': status,
    'patientId': patientId,
    'patientName': patientName,
    'assignedTime': assignedTime?.toIso8601String(),
    'type': type,
  };

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    id: json['id'] ?? '',
    number: json['number'] ?? json['id'] ?? '',
    floor: json['floor'] ?? '',
    status: json['status'] ?? 'Available',
    patientId: json['patientId'],
    patientName: json['patientName'],
    assignedTime: json['assignedTime'] != null
        ? DateTime.parse(json['assignedTime'])
        : null,
    type: json['type'],
  );
}