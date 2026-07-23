import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class DisplayNetworkImage extends StatefulWidget {
  const DisplayNetworkImage({
    super.key,
    required this.imageUrl,
    this.height, 
    this.width, 
    this.boxFit,
    this.fromPage,
    this.bigPlaceHolder
  });
      
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final String? fromPage;
  final bool? bigPlaceHolder;

  @override
  State<DisplayNetworkImage> createState() => _DisplayNetworkImageState();
}

class _DisplayNetworkImageState extends State<DisplayNetworkImage> {

  @override
  Widget build(BuildContext context) {
    return widget.imageUrl == "null" || widget.imageUrl.isEmpty
      ? placeHolder()
      : widget.imageUrl.toLowerCase().endsWith('.svg') 
        ? SvgPicture.network(
            widget.imageUrl,
            height: widget.height ?? 200.0.h,
            width: widget.width,
            fit: widget.boxFit ?? BoxFit.fitWidth,
            placeholderBuilder: (BuildContext context) => Container(
              height: widget.height,
              width: widget.width,
              alignment: Alignment.center,
              child: SizedBox(),
            ),
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Container(
                height: widget.height,
                width: widget.width,
                alignment: Alignment.center,
                child: Icon(Icons.broken_image, size: 24.sp, color: Colors.grey),
              );
            },
          )
        : widget.imageUrl.contains('assets/')
          ? placeHolder(widget.imageUrl)
          : CachedNetworkImage(
            fit: widget.boxFit ?? BoxFit.fitWidth,
            width: widget.width,
            height: widget.height,
            placeholder: (context, url) => ClipRRect(
              borderRadius: BorderRadius.circular(widget.fromPage == 'tutorial' ? 24.r : 5.r),
              child: const CustomShimmer(),
            ),
            imageUrl: widget.imageUrl,
            errorWidget: (context, url,_) => placeHolder(),
          );
  }

  Image placeHolder([String? imgUrl]) {
    return Image.asset(
      imgUrl ?? (widget.bigPlaceHolder != null && widget.bigPlaceHolder == true
          ? "assets/images/default.png"
          : "assets/icons/ball.png"),
      width: widget.width,
      height: widget.height,
      fit: widget.bigPlaceHolder != null && widget.bigPlaceHolder == true ? BoxFit.contain : BoxFit.cover,
    );
  }

}

class CustomShimmer extends StatelessWidget {
  const CustomShimmer({
    super.key,
    this.height = 30.0,
    this.width = 200.0,
    this.isCircular = false,
    this.radius,
  });
  final double? height;
  final double? width;
  final bool? isCircular;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:Colors.grey[300]!,
      highlightColor: Colors.grey[200]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(radius ?? 0),
        ),
      ),
    );
  }
}