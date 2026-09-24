import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/widgets/display_image.dart';

class ImageSlider extends StatefulWidget {
  final List imagePath;
  final bool? disableFullImgClick; 
  final double? height; // Added height parameter
  final double? width;  // Added width parameter

  const ImageSlider({
    super.key, 
    required this.imagePath, 
    this.disableFullImgClick,
    this.height,
    this.width,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height, 
      child: Stack(
        alignment: .bottomCenter,
        children: [
          CarouselSlider(
            items: widget.imagePath.map<Widget>((image) {
              final imageUrl = image is String ? image : image.fileUrl;
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DisplayNetworkImage(
                  imageUrl: imageUrl,
                  height: widget.height, 
                  width: widget.width ?? double.infinity,
                  boxFit: .cover, // Ensures image fills the available space
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: widget.height, // Passes the parent's height directly to the carousel
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),

          // Dot indicator overlay
          Positioned(
            bottom: 50,
            child: Container(
              padding: .symmetric(horizontal: 4.w, vertical: 2.h), 
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.5), 
                borderRadius: .circular(4.r),
              ),
              child: Row(
                mainAxisSize: .min, 
                mainAxisAlignment: .center,
                children: widget.imagePath.asMap().entries.map((entry) {
                  final index = entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: .symmetric(horizontal: 2.w),
                    width: currentIndex == index ? 10.w : 6.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? primaryColor
                          : primaryColor.withValues(alpha: 0.3),
                      borderRadius: .circular(4.r),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}