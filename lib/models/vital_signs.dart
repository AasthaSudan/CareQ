class VitalSigns {
  double? bloodPressure;  // Nullable double for blood pressure
  double? pulse;          // Nullable double for pulse
  double? temperature;    // Nullable double for temperature
  double? spO2;           // Nullable double for SpO2 (oxygen saturation)

  // Constructor for VitalSigns with optional parameters (nullable)
  VitalSigns({
    this.bloodPressure,
    this.pulse,
    this.temperature,
    this.spO2,
  });

  // CopyWith method to make the class immutable and update fields
  VitalSigns copyWith({
    double? bloodPressure,
    double? pulse,
    double? temperature,
    double? spO2,
  }) {
    return VitalSigns(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      pulse: pulse ?? this.pulse,
      temperature: temperature ?? this.temperature,
      spO2: spO2 ?? this.spO2,
    );
  }

  // FromMap method to convert Firestore document data into a VitalSigns object
  factory VitalSigns.fromMap(Map<String, dynamic> map) {
    return VitalSigns(
      bloodPressure: map['bloodPressure'] != null
          ? map['bloodPressure'].toDouble()
          : null,
      pulse: map['pulse'] != null ? map['pulse'].toDouble() : null,
      temperature: map['temperature'] != null
          ? map['temperature'].toDouble()
          : null,
      spO2: map['spO2'] != null ? map['spO2'].toDouble() : null,
    );
  }

  // ToMap method to convert the VitalSigns object into Firestore document data
  Map<String, dynamic> toMap() {
    return {
      'bloodPressure': bloodPressure,
      'pulse': pulse,
      'temperature': temperature,
      'spO2': spO2,
    };
  }
}
