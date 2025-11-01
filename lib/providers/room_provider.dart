import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool loading = false;
  List<RoomModel> rooms = [];

  RoomProvider() {
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    loading = true; notifyListeners();
    final snap = await _db.collection('rooms').orderBy('number').get();
    rooms = snap.docs.map((d) => RoomModel.fromMap(d.data(), d.id)).toList();
    loading = false; notifyListeners();
  }

  Future<void> assignRoom(String roomId, String patientId) async {
    await _db.collection('rooms').doc(roomId).update({'status': 'Occupied', 'patientId': patientId});
    await fetchRooms();
  }

  Future<void> releaseRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({'status': 'Cleaning', 'patientId': null});
    await fetchRooms();
  }
}
