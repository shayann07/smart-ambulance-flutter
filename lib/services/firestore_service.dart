import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Example: Add user data
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(userId).set(userData);
    } catch (e) {
      print('Error adding user to Firestore: $e');
      // Handle error appropriately
    }
  }

  // Example: Get user data
  Future<DocumentSnapshot?> getUser(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      print('Error getting user from Firestore: $e');
      return null;
    }
  }

  // Example: Add driver data
  Future<void> addDriver(String driverId, Map<String, dynamic> driverData) async {
    try {
      await _db.collection('drivers').doc(driverId).set(driverData);
    } catch (e) {
      print('Error adding driver to Firestore: $e');
    }
  }

  // Example: Update driver location
  Future<void> updateDriverLocation(String driverId, GeoPoint location) async {
    try {
      await _db.collection('drivers').doc(driverId).update({'location': location, 'last_updated': Timestamp.now()});
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  // Example: Create ambulance request
  Future<DocumentReference?> createAmbulanceRequest(Map<String, dynamic> requestData) async {
    try {
      return await _db.collection('requests').add(requestData);
    } catch (e) {
      print('Error creating ambulance request: $e');
      return null;
    }
  }

  // Example: Stream nearby available drivers (simplified)
  Stream<QuerySnapshot> getNearbyDrivers(GeoPoint userLocation) {
    // This is a simplified query. Real-world implementation would need GeoQueries (e.g., using geoflutterfire)
    // or more complex server-side logic for efficient spatial querying.
    return _db.collection('drivers')
              .where('is_available', isEqualTo: true)
              // Add geographic filtering logic here
              .limit(10) // Limit results for simplicity
              .snapshots();
  }

  // TODO: Add more specific methods as needed for requests, drivers, users, hospitals etc.
}

