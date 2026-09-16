import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/helper/url_launcher_helper.dart';
import 'package:futsal_dai/src/views/player/futsal_detail.dart';
import 'package:futsal_dai/src/widgets/custom_textfield.dart';
import 'package:futsal_dai/src/widgets/custom_toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Enum for the three search behavior types
enum MapSearchMode {
  placeOnly,    // 1. Search map places via Nominatim
  futsalOnly,   // 2. Search locally by futsal name in the passed venues list
  both,         // 3. Search both (tries local futsal match first, falls back to map place search)
}

// Model for multiple map venues
class MapVenueItem {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final dynamic originalData; // Passes full model to FutsalDetail

  MapVenueItem({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.originalData,
  });
}

class CustomMapScreen extends StatefulWidget {
  final double initialLat, initialLng;
  final bool isFullScreenView, showDirection, showCurrentLocation;
  final bool isSelectionMode;
  final bool enableSearch;
  final MapSearchMode searchMode; // Search mode flag
  final Function(LatLng selectedLocation)? onLocationSelected;
  final List<MapVenueItem> venues; // Multiple venues list
  final Future<List<MapVenueItem>> Function(String query)? onSearchVenues;
  final bool returnAddressOnLocation;

  const CustomMapScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
    this.showDirection = false,
    this.showCurrentLocation = false,
    this.isFullScreenView = false,
    this.isSelectionMode = false,
    this.enableSearch = false,
    this.searchMode = MapSearchMode.placeOnly, // Default to normal map search
    this.onLocationSelected,
    this.venues = const [],
    this.onSearchVenues,
    this.returnAddressOnLocation = false
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

  // Search suggestion dropdown state
  Timer? _suggestionDebounce;
  List<Map<String, dynamic>> searchSuggestions = [];
  bool showSuggestions = false;

  // For route
  List<LatLng> routePoints = [];
  bool isLoadingRoute = false;

  // Track active popup venue card
  MapVenueItem? activePopupVenue;

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
    _suggestionDebounce?.cancel();
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
    
    // Update coordinates if initial lat/lng changed
    if (oldWidget.initialLat != widget.initialLat || oldWidget.initialLng != widget.initialLng) {
      setState(() {
        selectedLocation = LatLng(widget.initialLat, widget.initialLng);
      });
    }

    // If venues list updates from empty to loaded, center camera on the first venue
    if (oldWidget.venues.isEmpty && widget.venues.isNotEmpty) {
      setState(() {
        selectedLocation = LatLng(widget.venues.first.lat, widget.venues.first.lng);
      });
      mapController.move(selectedLocation, 14.0);
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
        selectedLocation = userLatLng;
      });

      mapController.move(userLatLng, 15.0);

      startLocationUpdates();

      if (widget.returnAddressOnLocation && widget.onLocationSelected != null) {
        widget.onLocationSelected!(userLatLng);
      }
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => isLoadingLocation = false);
    }
  }

  void _onSearchChanged(String value) {
    _suggestionDebounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        searchSuggestions.clear();
        showSuggestions = false;
      });
      return;
    }

    _suggestionDebounce = Timer(const Duration(milliseconds: 400), _loadSuggestions);
  }

  void _openSuggestions() {
    _suggestionDebounce?.cancel();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final rawQuery = searchController.text.trim();
    final query = rawQuery.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        searchSuggestions.clear();
        showSuggestions = false;
        isLoadingSearch = false;
      });
      return;
    }

    setState(() => isLoadingSearch = true);

    List<Map<String, dynamic>> suggestions = [];

    // 1. Local futsal venue matches
    if (widget.searchMode == MapSearchMode.futsalOnly || widget.searchMode == MapSearchMode.both) {
      // Use server-side search (loadAllVenues) when the host screen provides a callback
      if (widget.onSearchVenues != null) {
        try {
          final matches = await widget.onSearchVenues!(rawQuery);
          suggestions.addAll(matches.map((v) => {
            'type': 'venue',
            'title': v.name,
            'subtitle': v.address,
            'venue': v,
            'lat': v.lat,
            'lng': v.lng,
          }));
        } catch (_) {
          // Ignore server-side search errors silently, fall back to local list below
          final matches = widget.venues.where((v) => v.name.toLowerCase().contains(query)).toList();
          suggestions.addAll(matches.map((v) => {
            'type': 'venue',
            'title': v.name,
            'subtitle': v.address,
            'venue': v,
            'lat': v.lat,
            'lng': v.lng,
          }));
        }
      } else {
        final matches = widget.venues.where((v) => v.name.toLowerCase().contains(query)).toList();
        suggestions.addAll(matches.map((v) => {
          'type': 'venue',
          'title': v.name,
          'subtitle': v.address,
          'venue': v,
          'lat': v.lat,
          'lng': v.lng,
        }));
      }
    }

    // 2. Online place matches via Nominatim
    if (widget.searchMode == MapSearchMode.placeOnly || widget.searchMode == MapSearchMode.both) {
      try {
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(rawQuery)}&format=json&limit=5');

        final response = await http.get(url, headers: {
          'User-Agent': 'com.trend74x.futsaldai',
        });

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          for (final item in data) {
            suggestions.add({
              'type': 'place',
              'title': item['display_name']?.toString() ?? 'Unknown location',
              'subtitle': '',
              'venue': null,
              'lat': double.parse(item['lat'].toString()),
              'lng': double.parse(item['lon'].toString()),
            });
          }
        }
      } catch (_) {
        // Ignore online suggestion errors silently
      }
    }

    if (!mounted) return;

    setState(() {
      searchSuggestions = suggestions;
      showSuggestions = suggestions.isNotEmpty;
      isLoadingSearch = false;
    });
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    FocusScope.of(context).unfocus();
    _suggestionDebounce?.cancel();

    final venue = suggestion['venue'] as MapVenueItem?;
    final newLocation = LatLng(
      suggestion['lat'] as double,
      suggestion['lng'] as double,
    );

    // Show result at the bottom and follow the regular flow only on selection
    setState(() {
      selectedLocation = newLocation;
      routePoints.clear();
      activePopupVenue = venue; // venue → preview card at bottom, place → null
      searchSuggestions.clear();
      showSuggestions = false;
    });

    mapController.move(newLocation, 16.0);

    // For place selections (selection mode), report the picked location
    if (venue == null && widget.onLocationSelected != null) {
      widget.onLocationSelected!(newLocation);
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
            searchMode: widget.searchMode, // Pass search mode forward
            venues: widget.venues, 
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
                  ? InteractiveFlag.all // Full map controls in fullscreen
                  : (InteractiveFlag.pinchZoom | InteractiveFlag.drag), // Pan/zoom enabled
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
                    activePopupVenue = null;      
                    showSuggestions = false;
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
                userAgentPackageName: 'com.trend74x.futsaldai',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6.0,
                      color: primaryColor,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // 1. Render multiple venue markers
                  ...widget.venues.map((venue) {
                    bool isSelected = activePopupVenue?.id == venue.id;
                    return Marker(
                      point: LatLng(venue.lat, venue.lng),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            activePopupVenue = venue;
                            selectedLocation = LatLng(venue.lat, venue.lng);
                            showSuggestions = false;
                          });
                          mapController.move(LatLng(venue.lat, venue.lng), mapController.camera.zoom);
                        },
                        child: Icon(
                          Icons.location_on,
                          color: isSelected ? primaryColor : Colors.red,
                          size: isSelected ? 45 : 35,
                        ),
                      ),
                    );
                  }),

                  // 2. Fallback single marker if no venues list provided
                  if (widget.venues.isEmpty)
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

                  // 3. Current user location marker
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
                  shape: BoxShape.circle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
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
                      textInputAction: TextInputAction.search,
                      hintText: widget.searchMode == MapSearchMode.futsalOnly 
                          ? 'Search Futsal Name...' 
                          : widget.searchMode == MapSearchMode.both 
                              ? 'Search Futsal or Place...' 
                              : 'Search Location...',
                      onChanged: _onSearchChanged,
                      onFieldSubmitted: (_) => _openSuggestions(),
                      suffixIcon: isLoadingSearch
                        ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(strokeWidth: 3),
                        )
                        : IconButton(
                          icon: const Icon(Icons.search, color: primaryColor),
                          onPressed: _openSuggestions,
                        ),
                    ),
                  ),
                  // --- Suggested results dropdown below the search field ---
                  if (showSuggestions)
                    Container(
                      margin: EdgeInsets.only(top: 6.h),
                      constraints: BoxConstraints(maxHeight: 280.h),
                      decoration: BoxDecoration(
                        color: containerBgColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: searchSuggestions.length,
                        separatorBuilder: (_, i) => Divider(
                          height: 1,
                          color: subtitleTextColor.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> suggestion = searchSuggestions[index];
                          final bool isVenue = suggestion['type'] == 'venue';
                          return InkWell(
                            onTap: () => _onSuggestionSelected(suggestion),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  Icon(
                                    isVenue ? Icons.sports_soccer : Icons.place_outlined,
                                    color: primaryColor,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          suggestion['title']?.toString() ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((suggestion['subtitle']?.toString() ?? '').isNotEmpty)
                                          Text(
                                            suggestion['subtitle'].toString(),
                                            style: TextStyle(
                                              color: subtitleTextColor,
                                              fontSize: 12.sp,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
      
          // --- Floating Overlay Buttons ---
          Positioned(
            top: widget.enableSearch
              ? (widget.isFullScreenView ? 130.h : 71.h)
              : (widget.isFullScreenView ? 70.h : 16.h),
            right: 16.w,
            child: Column(
              children: [
                if (!widget.isFullScreenView)
                  FloatingActionButton.small(
                    heroTag: 'fullscreen_enter_btn',
                    backgroundColor: lightFilledBgColor,
                    onPressed: () => _openFullScreenMap(context),
                    child: const Icon(Icons.fullscreen, color: primaryColor),
                  ),
                if (widget.showCurrentLocation) ...[
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
                if (widget.showDirection) ...[
                  SizedBox(height: 8.h),
                  FloatingActionButton.small(
                    heroTag: 'share_to_map',
                    backgroundColor: lightFilledBgColor,
                    onPressed: () => launchMapDirections(latitude: widget.initialLat, longitude: widget.initialLng),
                    child: const Icon(Icons.map_outlined, color: primaryColor),
                  ),
                ],
              ],
            ),
          ),

          // --- Venue Preview Card Dialog Popup Overlay ---
          if (activePopupVenue != null)
            Positioned(
              bottom: 30.h,
              left: 20.w,
              right: 20.w,
              child: GestureDetector(
                onTap: () {
                  Get.to(() => FutsalDetail(data: activePopupVenue!.originalData));
                },
                child: Container(
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: containerBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: primaryColor, width: 1.w),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activePopupVenue!.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              activePopupVenue!.address,
                              style: TextStyle(
                                color: subtitleTextColor,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'View',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
}