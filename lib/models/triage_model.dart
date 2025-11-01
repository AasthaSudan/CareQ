class TriageModel {
  final String level; // Critical/Urgent/Stable
  final double? confidence;
  final String? recommendation;
  final DateTime? createdAt;

  TriageModel({required this.level, this.confidence, this.recommendation, this.createdAt});

  Map<String, dynamic> toMap() => {
    'level': level,
    'confidence': confidence,
    'recommendation': recommendation,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory TriageModel.fromMap(Map<String, dynamic> m) {
    DateTime? dt;
    if (m['createdAt'] != null) {
      try {
        dt = DateTime.parse(m['createdAt']);
      } catch (_) {}
    }
    return TriageModel(level: m['level'] ?? 'Unknown', confidence: (m['confidence'] as num?)?.toDouble(), recommendation: m['recommendation'], createdAt: dt);
  }
}
