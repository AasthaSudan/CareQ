// import 'dart:math';
// import 'package:flutter/material.dart';
//
// class AIPriorityService {
//   // Main AI prediction method
//   static Map<String, dynamic> predictPriority({
//     required int age,
//     required int pulse,
//     required String bloodPressure,
//     required double temperature,
//     required int oxygenLevel,
//     required List<String> symptoms,
//   }) {
//     // Calculate comprehensive risk score (0-100)
//     double riskScore = 0;
//     List<String> riskFactors = [];
//
//     // Age-based risk
//     if (age > 70) {
//       riskScore += 18;
//       riskFactors.add('Advanced age (>70)');
//     } else if (age > 60) {
//       riskScore += 12;
//       riskFactors.add('Elderly patient (>60)');
//     } else if (age < 2) {
//       riskScore += 22;
//       riskFactors.add('Infant patient (<2)');
//     } else if (age < 12) {
//       riskScore += 8;
//       riskFactors.add('Pediatric patient');
//     }
//
//     // Pulse risk analysis
//     if (pulse > 140) {
//       riskScore += 25;
//       riskFactors.add('Severe tachycardia (>140 bpm)');
//     } else if (pulse > 120) {
//       riskScore += 18;
//       riskFactors.add('Tachycardia (>120 bpm)');
//     } else if (pulse > 100) {
//       riskScore += 10;
//       riskFactors.add('Elevated heart rate (>100 bpm)');
//     } else if (pulse < 45) {
//       riskScore += 22;
//       riskFactors.add('Severe bradycardia (<45 bpm)');
//     } else if (pulse < 55) {