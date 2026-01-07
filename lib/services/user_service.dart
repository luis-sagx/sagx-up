import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          level: data['level'] ?? 'Principiante',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return AppUser(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          level: data['level'] ?? 'Principiante',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }
      return null;
    });
  }
}
