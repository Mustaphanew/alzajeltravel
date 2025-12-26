import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

import 'app_consts.dart';
import 'package:dotted_line/dotted_line.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text("No data".tr, style: TextStyle(fontSize: 16, color: Colors.black)),
        ),
      ),
    );
  }
}

class ErrorData extends StatelessWidget {
  const ErrorData({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      color: Colors.white,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Text("Server problem".tr, style: TextStyle(color: Colors.red, fontSize: 16)),
        ),
      ),
    );
  }
}

class LoadingData extends StatelessWidget {
  final double size;

  const LoadingData({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 5,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              (Get.isDarkMode) ? AppConsts.secondaryColor : AppConsts.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class CacheImg extends StatelessWidget {
  final String url;
  final BoxFit? boxFit;
  final imgWidth;
  double sizeCircleLoading = 30;

  CacheImg(this.url, {super.key, this.boxFit = BoxFit.cover, this.sizeCircleLoading = 30, this.imgWidth});

  @override
  Widget build(BuildContext context) {
    String imageUrl;
    if (url == "" || url == " ") {
      imageUrl = "";
    }
    if (url.contains("http")) {
      imageUrl = url;
    } else {
      imageUrl = "$url";
    }
    // print("imageUrl: $imageUrl");
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: boxFit,
      width: imgWidth,
      placeholder: (context, url) {
        return Container(
          padding: EdgeInsets.all(4),
          // height: sizeCircleLoading + 10.0,
          // width: sizeCircleLoading + 10.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: sizeCircleLoading,
                width: sizeCircleLoading,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        );
      },
      errorWidget: (context, url, error) {
        return SvgPicture.asset(AppConsts.logoBlack, color: Colors.grey[500]);
      },
    );
  }
}

class CacheImgGallery extends StatelessWidget {
  final String url;
  final BoxFit boxFit;
  final Function? onClick;
  final Function? onLongClick;

  const CacheImgGallery(this.url, {super.key, this.boxFit = BoxFit.cover, this.onClick, this.onLongClick});

  @override
  Widget build(BuildContext context) {
    // print("${v.storageLink}${imageName}");
    final rand = Random().nextInt(1000000).toString();
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: Hero(
            tag: "${url}_$rand",
            child: CacheImg(url, boxFit: boxFit),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
          child: TextButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            onPressed: (onClick == null)
                ? () async {
                    SwipeImageGallery(
                      context: context,
                      // children: [Image(image: AssetImage('assets/images/logo.png')),],
                      children: [CacheImg(url, boxFit: BoxFit.contain)],
                      initialIndex: 0,
                      heroProperties: [ImageGalleryHeroProperties(tag: "${url}_$rand")],
                      hideStatusBar: false,
                    ).show();
                  }
                : () => onClick,
            onLongPress: (onLongClick == null)
                ? () async {
                    SwipeImageGallery(
                      context: context,
                      // children: [Image(image: AssetImage('assets/images/logo.png')),],
                      children: [CacheImg(url, boxFit: BoxFit.contain)],
                      initialIndex: 0,
                      heroProperties: [ImageGalleryHeroProperties(tag: "${url}_$rand")],
                      hideStatusBar: false,
                    ).show();
                  }
                : () => onLongClick,
            child: Text(""),
          ),
        ),
      ],
    );
  }
}

class FlightLoader extends StatefulWidget {
  final double? imgSize;
  final Widget? title;

  const FlightLoader({super.key, this.imgSize, this.title});

  @override
  State<FlightLoader> createState() => _FlightLoaderState();
}

class _FlightLoaderState extends State<FlightLoader> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String flightLoader = Get.isDarkMode
        ? AppConsts
              .flightLoaderDark // مسار GIF للوضع الداكن
        : AppConsts.flightLoaderLight; // مسار GIF للوضع الفاتح

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            flightLoader,
            width: widget.imgSize ?? 350, // غيّر المقاس لو حاب
            height: widget.imgSize ?? 350,
            fit: BoxFit.contain,
            color: Colors.amber,
          ),
          if (widget.title != null) widget.title!,
        ],
      ),
    );
  }
}

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DottedLine(lineThickness: 1.67, dashGapLength: 6, dashLength: 6, dashColor: cs.primaryFixed);
  }
}
