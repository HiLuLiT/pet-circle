import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_circle/models/app_notification.dart';

class NotificationService {
  static final _firestore = FirebaseFirestore.instance;
  static final _usersCollection = _firestore.collection('users');

  static CollectionReference<Map<String, dynamic>> _notificationsRef(String uid) =>
      _usersCollection.doc(uid).collection('notifications');

  static Stream<List<AppNotification>> streamNotifications(String uid) {
    return _notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList());
  }

  static Future<void> addNotification(
    String uid,
    AppNotification notification,
  ) async {
    await _notificationsRef(uid).add(notification.toFirestore());
  }

  static Future<void> markRead(String uid, String notificationId) async {
    await _notificationsRef(uid).doc(notificationId).update({
      'isRead': true,
    });
  }

  static Future<void> markAllRead(String uid) async {
    final unreadSnapshot = await _notificationsRef(uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
