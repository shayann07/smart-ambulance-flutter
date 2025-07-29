import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';
import 'package:smart_ambulance_app/services/firestore_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  GoogleMapController? _mapController;
  Location _location = Location();
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isAvailable = true; // Driver's availability status
  bool _isLoading = true;
  DocumentSnapshot? _assignedRequest;
  StreamSubscription? _requestSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDriverState();
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    super.dispose();
  }

  void _initializeDriverState() async {
    await _getCurrentLocationAndTrack();
    // TODO: Fetch initial availability status from Firestore if stored
    // TODO: Start listening for assigned requests
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocationAndTrack() async {
    // Similar location permission and service checks as UserHomeScreen
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await _location.requestService();
    if (!serviceEnabled) return; // Handle error

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }
    if (permissionGranted != PermissionStatus.granted) return; // Handle error

    _currentLocation = await _location.getLocation();
    _updateDriverLocationInFirestore(_currentLocation);
    _updateMarkers();

    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
          _updateMarkers();
        });
        _updateDriverLocationInFirestore(currentLocation);
      }
    });
  }

  void _updateDriverLocationInFirestore(LocationData? locationData) {
    if (locationData != null && _auth.currentUser != null) {
      _firestore.updateDriverLocation(
        _auth.currentUser!.uid,
        GeoPoint(locationData.latitude!, locationData.longitude!),
      );
    }
  }

  void _updateMarkers() {
    if (_currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('driverLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      // TODO: Add marker for patient location if request is assigned
      // TODO: Add marker for destination hospital if request is assigned
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _toggleAvailability(bool value) {
    setState(() {
      _isAvailable = value;
    });
    // Update availability status in Firestore
    if (_auth.currentUser != null) {
      _firestore.addDriver(_auth.currentUser!.uid, {'is_available': _isAvailable}); // Using addDriver to update/set
    }
  }

  // TODO: Implement functions to accept/reject requests
  // TODO: Implement functions to update request status (e.g., picked up, reached hospital)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // Navigate back to login screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Available for Requests:'),
                      Switch(
                        value: _isAvailable,
                        onChanged: _toggleAvailability,
                      ),
                    ],
                  ),
                ),
                // TODO: Display assigned request details if any
                // if (_assignedRequest != null) ...[
                //   Text('Assigned Request: Patient at ...'),
                //   ElevatedButton(onPressed: () {/* Accept */}, child: Text('Accept')),
                //   ElevatedButton(onPressed: () {/* Reject */}, child: Text('Reject')),
                // ],
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation != null
                          ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                          : const LatLng(0, 0),
                      zoom: 15.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: false, // Driver marker is custom
                    myLocationButtonEnabled: true,
                  ),
                ),
              ],
            ),
      // TODO: Add buttons for updating status (e.g., 'Patient Picked Up', 'Reached Hospital')
    );
  }
}

