import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CustomMapScreen extends StatefulWidget {
  final double initialLat, initialLng;
  final bool isFullScreenView, showDirection, showCurrentLocation;
  final bool isSelectionMode;
  final bool enableSearch;
  final Function(LatLng selectedLocation)? onLocationSelected;

  const CustomMapScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.showDirection = false,
    this.showCurrentLocation = false,
    this.isFullScreenView = false,
    this.isSelectionMode = false,
    this.enableSearch = false,
    this.onLocationSelected,
  });

  @override
  State<CustomMapScreen> createState() => _CustomMapScreenState();
}

class _CustomMapScreenState extends State<CustomMapScreen> {
  late final MapController mapController;
  late final TextEditingController searchController;
  StreamSubscription<Position>? positionStream;

  LatLng? currentLocation;
  late LatLng selectedLocation;
  
  bool isLoadingLocation = false;
  bool isLoadingSearch = false;

  // For route
  List<LatLng> routePoints = [];
  bool isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    searchController = TextEditingController();
    selectedLocation = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  void dispose() {
    positionStream?.cancel(); 
    searchController.dispose(); 
    super.dispose();
  }

  void startLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLat != widget.initialLat || oldWidget.initialLng != widget.initialLng) {
      setState(() {
        selectedLocation = LatLng(widget.initialLat, widget.initialLng);
      });
    }
  }

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

  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => isLoadingSearch = true);
    FocusScope.of(context).unfocus();

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');

      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.futsal_dai',
      });

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          final double lat = double.parse(data[0]['lat']);
          final double lon = double.parse(data[0]['lon']);
          final newLocation = LatLng(lat, lon);

          setState(() {
            selectedLocation = newLocation;
            routePoints.clear(); 
          });

          mapController.move(newLocation, 15.0);

          if (widget.onLocationSelected != null) {
            widget.onLocationSelected!(newLocation);
          }
        } else {
          _showSnackBar('Location not found. Try a different name.');
        }
      } else {
        _showSnackBar('Failed to search location.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoadingSearch = false);
    }
  }

  Future<void> fetchRoute() async {
    if (currentLocation == null) {
      _showSnackBar('Please get your current location first.');
      return;
    }

    setState(() => isLoadingRoute = true);

    try {
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
          routePoints = coordinates
              .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
              .toList();
        });

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
    showToast(message: message, isSuccess: true);
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CustomMapScreen(
            initialLat: selectedLocation.latitude,
            initialLng: selectedLocation.longitude,
            isFullScreenView: true,
            isSelectionMode: widget.isSelectionMode, 
            showCurrentLocation: widget.showCurrentLocation,
            showDirection: widget.showDirection,
            enableSearch: widget.enableSearch, 
            onLocationSelected: (newLocation) {
              setState(() {
                selectedLocation = newLocation;
              });
              mapController.move(newLocation, mapController.camera.zoom);
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
    return Scaffold(
      body: Stack(
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
              onTap: (widget.isSelectionMode && widget.isFullScreenView && !widget.showDirection)
                ? (tapPosition, point) {
                  FocusScope.of(context).unfocus();
                  
                  setState(() {
                    selectedLocation = point; 
                    routePoints.clear();      
                  });
      
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
      
          if (widget.isFullScreenView)
            Positioned(
              top: 70.h,
              left: 16.w,
              child: Container(
                height: 45.h,
                width: 45.w,
                decoration: const BoxDecoration(
                  color: filledBgColor,
                  shape: .circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
      
          // --- Search Bar Overlay ---
          if (widget.enableSearch)
            Positioned(
              top: widget.isFullScreenView ? 60.h : 16.h,
              left: widget.isFullScreenView ? 70.w : 16.w,
              right: 20.w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
                  ],
                ),
                child: CustomTextFormField(
                  controller: searchController,
                  headingText: '',
                  textInputAction: .search,
                  hintText: 'Search Location...',
                  onFieldSubmitted: searchPlace,
                  suffixIcon: isLoadingSearch
                    ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(strokeWidth: 3),
                    )
                    : IconButton(
                      icon: const Icon(Icons.search, color: primaryColor),
                      onPressed: () => searchPlace(searchController.text),
                    ),
                ),
              ),
            ),
      
          // --- Floating Overlay Buttons ---
          Positioned(
            top: widget.enableSearch
              ? (widget.isFullScreenView ? 120.h : 71.h)
              : (widget.isFullScreenView ? 70.h : 16.h),
            right: 16.w,
            child: Column(
              children: [
                // HIDE the Fullscreen enter button if we are already in fullscreen
                if (!widget.isFullScreenView)
                  FloatingActionButton.small(
                    heroTag: 'fullscreen_enter_btn',
                    backgroundColor: lightFilledBgColor,
                    onPressed: () => _openFullScreenMap(context),
                    child: const Icon(Icons.fullscreen, color: primaryColor),
                  ),
                if (widget.showCurrentLocation) ...[
                  // Adds space only if the fullscreen button is visible, 
                  // to prevent extra gap at the top in fullscreen mode
                  if (!widget.isFullScreenView) SizedBox(height: 8.h),
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
                      if (currentLocation == null) {
                        await locateUser();
                      }
                      fetchRoute();
                    },
                    child: const Icon(Icons.directions_outlined, color: primaryColor),
                  ),
                ],
              ],
            ),
          ),

          if (widget.isFullScreenView)
            Positioned(
              top: 240.h,
              right: 16.w,
              child: FloatingActionButton.small(
                heroTag: 'share_to_map',
                backgroundColor: lightFilledBgColor,
                onPressed: () => launchMapDirections(latitude: widget.initialLat, longitude: widget.initialLng),
                child: const Icon(Icons.map_outlined, color: primaryColor),
              ),
            ),
        ],
      ),
    );
  }
  
}