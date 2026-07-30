import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CustomMapScreen extends StatefulWidget {
  final double initialLat, initialLng;
  final bool isFullScreenView, showDirection, showCurrentLocation;
  final bool isSelectionMode;
  final Function(LatLng selectedLocation)? onLocationSelected;

  const CustomMapScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.showDirection = false,
    this.showCurrentLocation = false,
    this.isFullScreenView = false,
    this.isSelectionMode = false,
    this.onLocationSelected,
  });

  @override
  State<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<CustomMapScreen> {
  late final MapController mapController;
  StreamSubscription<Position>? positionStream;

  LatLng? currentLocation;
  late LatLng selectedLocation;
  
  bool isLoadingLocation = false;

  // For route
  List<LatLng> routePoints = [];
  bool isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    selectedLocation = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Always clean up your streams
    super.dispose();
  }

  void startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Triggers update every 5 meters walked
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Optional: Keep camera centered on the walking user
      mapController.move(currentLocation!, mapController.camera.zoom);
    });
  }

  // Handle external parameter updates
  @override
  void didUpdateWidget(covariant CustomMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLat != widget.initialLat || oldWidget.initialLng != widget.initialLng) {
      setState(() {
        selectedLocation = LatLng(widget.initialLat, widget.initialLng);
      });
    }
  }

  // Handle location permissions and move map to user
  Future<void> locateUser() async {
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        currentLocation = userLatLng;
      });

      mapController.move(userLatLng, 15.0);

      startLocationUpdates();
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => isLoadingLocation = false);
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null) {
      _showSnackBar('Please get your current location first.');
      return;
    }

    setState(() => isLoadingRoute = true);

    try {
      // OSRM expects coordinates in format: {longitude},{latitude}
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${currentLocation!.longitude},${currentLocation!.latitude};'
        '${selectedLocation.longitude},${selectedLocation.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

        setState(() {
          // OSRM returns GeoJSON coordinates [lng, lat] -> convert to LatLng(lat, lng)
          routePoints = coordinates
              .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
              .toList();
        });

        // Optional: Fit map bounds to show the entire route line
        final bounds = LatLngBounds.fromPoints([currentLocation!, selectedLocation]);
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50.0),
          ),
        );
      } else {
        _showSnackBar('Failed to fetch route directions.');
      }
    } catch (e) {
      _showSnackBar('Error fetching route: $e');
    } finally {
      setState(() => isLoadingRoute = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Opens map in a true Fullscreen Page Route
  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CustomMapScreen(
            initialLat: selectedLocation.latitude,
            initialLng: selectedLocation.longitude,
            isFullScreenView: true,
            isSelectionMode: widget.isSelectionMode, // Pass selection mode state
            showCurrentLocation: widget.showCurrentLocation,
            showDirection: widget.showDirection,
            onLocationSelected: (newLocation) {
              // 1. Update internal state on screen exit/return
              setState(() {
                selectedLocation = newLocation;
              });

              // 2. Pan background camera to selected coordinates
              mapController.move(newLocation, mapController.camera.zoom);

              // 3. Notify parent widget tree
              if (widget.onLocationSelected != null) {
                widget.onLocationSelected!(newLocation);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: selectedLocation,
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(
              flags: widget.isFullScreenView
                ? InteractiveFlag.all
                : InteractiveFlag.none
            ),
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(-90, -180),
                const LatLng(90, 180),
              ),
            ),
            // MAP TAP DETECTION
            onTap: (widget.isSelectionMode && widget.isFullScreenView && !widget.showDirection)
              ? (tapPosition, point) {
                setState(() {
                  selectedLocation = point; // Move marker coordinate
                  routePoints.clear();      // Clear old route lines
                });

                // Send data back to parent callback
                if (widget.onLocationSelected != null) {
                  widget.onLocationSelected!(point);
                }
              }
              : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.futsal_dai',
            ),
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6.0,
                    color: textBlue,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Selected Location Marker
                Marker(
                  point: selectedLocation,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                // User Current Location Marker (Blue Dot)
                if (currentLocation != null)
                  Marker(
                    point: currentLocation!,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: textBlue.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: textBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Floating Overlay Buttons
        Positioned(
          top: widget.isFullScreenView ? 50.h : 16.h,
          right: 16.w,
          child: Column(
            children: [
              // Fullscreen Toggle
              FloatingActionButton.small(
                heroTag: widget.isFullScreenView ? 'fullscreen_exit_btn' : 'fullscreen_enter_btn',
                backgroundColor: lightFilledBgColor,
                onPressed: () {
                  if (widget.isFullScreenView) {
                    Navigator.of(context).pop();
                  } else {
                    _openFullScreenMap(context);
                  }
                },
                child: Icon(
                  widget.isFullScreenView ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: primaryColor,
                ),
              ),
              if (widget.showCurrentLocation) ...[
                SizedBox(height: 8.h),
                FloatingActionButton.small(
                  heroTag: widget.isFullScreenView ? 'loc_btn_full' : 'loc_btn_small',
                  backgroundColor: lightFilledBgColor,
                  onPressed: locateUser,
                  child: isLoadingLocation
                    ? SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.my_location, color: primaryColor),
                ),
              ],
              if (widget.showDirection) ...[
                SizedBox(height: 8.h),
                FloatingActionButton.small(
                  heroTag: widget.isFullScreenView ? 'directions_full' : 'directions_small',
                  backgroundColor: lightFilledBgColor,
                  onPressed: () async {
                    // Fetch user location first if not already available
                    if (currentLocation == null) {
                      await locateUser();
                    }
                    fetchRoute();
                  },
                  // onPressed: () => launchMapDirections(
                  //   latitude: selectedLocation.latitude,
                  //   longitude: selectedLocation.longitude,
                  // ),
                  child: const Icon(Icons.directions_outlined, color: primaryColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}