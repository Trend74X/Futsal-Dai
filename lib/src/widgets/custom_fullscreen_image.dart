import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ViewFullScreenImage extends StatefulWidget {
  final String? imageUrl;
  final String? id;

  const ViewFullScreenImage({super.key, this.imageUrl, this.id});

  @override
  State<ViewFullScreenImage> createState() => _ViewFullScreenImageState();
}

class _ViewFullScreenImageState extends State<ViewFullScreenImage> {
  final TransformationController _transformationController = TransformationController();
  bool _heroCompleted = false;
  late TapDownDetails _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    // Enable zoom after Hero animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _heroCompleted = true);
    });
  }

  @override
  void dispose() {
    // Restore status bar
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity(); // reset zoom
    } else {
      final position = _doubleTapDetails.localPosition;
      // Zoom in 3x on double tap at the tapped position
      _transformationController.value = Matrix4.identity()
        ..translateByDouble(-position.dx * 2, -position.dy * 2, 0.0, 1.0)
        ..scaleByDouble(3.0, 3.0, 3.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.95),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: _heroCompleted,
              scaleEnabled: _heroCompleted,
              constrained: false, // allows zoom beyond screen
              minScale: 1.0, // start at fitted size
              maxScale: 5.0, // allow up to 5x zoom
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: widget.imageUrl != null && widget.imageUrl != "null"
                    ? Hero(
                      tag: widget.id ?? '',
                      transitionOnUserGestures: true,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl!,
                        fit: BoxFit.contain, // fits to screen initially
                        placeholder: (context, url) => _placeHolder(context),
                        errorWidget: (context, url, _) => _placeHolder(context),
                      ),
                    )
                    : _placeHolder(context),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeHolder(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Image.asset(
        "assets/images/no-image.jpg",
        fit: BoxFit.contain,
      ),
    );
  }

}