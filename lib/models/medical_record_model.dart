class MedicalRecordModel {
  String recordId;
  String patientId;
  String documentName;
  String documentURL;  // URL to access the medical record document

  MedicalRecordModel({
    required this.recordId,
    required this.patientId,
    required this.documentName,
    required this.documentURL,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'patientId': patientId,
      'documentName': documentName,
      'documentURL': documentURL,
    };
  }

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      recordId: map['recordId'],
      patientId: map['patientId'],
      documentName: map['documentName'],
      documentURL: map['documentURL'],
    );
  }
}
