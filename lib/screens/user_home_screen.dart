import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:smart_ambulance_app/services/auth_service.dart';
import 'package:smart_ambulance_app/services/firestore_service.dart';
// Import other necessary services or models

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();
  GoogleMapController? _mapController;
  Location _location = Location();
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        // Handle case where location services are disabled
        setState(() => _isLoading = false);
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Handle case where location permission is denied
        setState(() => _isLoading = false);
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Update user's location in Firestore (optional, consider frequency)
      // _firestore.updateUserLocation(_auth.currentUser!.uid, GeoPoint(currentLocation.latitude!, currentLocation.longitude!));
      if (mounted) {
         setState(() {
           _currentLocation = currentLocation;
           _updateMarkers();
           // Optionally move camera
           // _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(currentLocation.latitude!, currentLocation.longitude!)));
         });
      }
    });

    setState(() {
      _isLoading = false;
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    if (_currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      // TODO: Add markers for nearby available ambulances/drivers based on Firestore stream
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Apply custom map style if needed based on design
  }

  void _requestAmbulance() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot determine your location.')),
      );
      return;
    }

    // Show confirmation dialog or proceed directly
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ambulance Request'),
        content: const Text('Do you want to request an ambulance to your current location?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Request'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              setState(() => _isLoading = true); // Show loading indicator

              // Create request in Firestore
              final requestData = {
                'userId': _auth.currentUser!.uid,
                'userName': _auth.currentUser!.displayName ?? 'Unknown User', // Or fetch from Firestore user profile
                'location': GeoPoint(_currentLocation!.latitude!, _currentLocation!.longitude!),
                'requestTime': Timestamp.now(),
                'status': 'pending', // Initial status
                // Add other relevant details
              };
              DocumentReference? requestRef = await _firestore.createAmbulanceRequest(requestData);

              setState(() => _isLoading = false); // Hide loading indicator

              if (requestRef != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ambulance requested successfully!')), // TODO: Navigate to a request status screen
                );
                // TODO: Start listening to request status updates
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to request ambulance. Please try again.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home - Request Ambulance'),
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
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation != null
                        ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                        : const LatLng(0, 0), // Default location if current location is null
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true, // Shows blue dot for user location
                  myLocationButtonEnabled: true,
                ),
                // TODO: Add UI elements for driver tracking, ETA, etc.
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _requestAmbulance,
        label: const Text('Request Ambulance'),
        icon: const Icon(Icons.local_hospital),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

