import 'package:flutter/material.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets.dart';

class FlightCardVertical extends StatelessWidget {
  final String from;
  final String to;
  final String imageUrl;
  final double price;
  final Color bgList;

  const FlightCardVertical({
    super.key,
    required this.from,
    required this.to,
    required this.imageUrl,
    required this.price,
    this.bgList = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      // color: bgList, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                offset: const Offset(0, 3),
                color: AppConsts.primaryColor.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ صورة الرحلة
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CacheImg(AppConsts.imageUrl + imageUrl),
              ),

              // ✅ تفاصيل الرحلة
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏙️ من -> إلى
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "$from  ⇄  $to",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 💰 السعر
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        children: [
                          const TextSpan(text: "Starting From "),
                          TextSpan(
                            text: "USD ",
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                              fontSize: AppConsts.lg,
                            ),
                          ),
                          TextSpan(
                            text: price.toStringAsFixed(0),
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.w600,
                              fontSize: AppConsts.lg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 🔘 الزر
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          // backgroundColor: Colors.blue[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.navigate_before,
                          size: 26,
                        ),
                        label: const Text(
                          "Book Now",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlightCardHorizontal extends StatelessWidget {
  final double listViewHorizontalHeight;
  final String imageUrl;
  final String from;
  final String to;
  final String price;

  const FlightCardHorizontal({
    super.key,
    required this.imageUrl,
    required this.from,
    required this.to,
    required this.price,
    required this.listViewHorizontalHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 3),
            color: AppConsts.primaryColor.withValues(alpha: 0.15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: SizedBox(
          width: 260,

          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(child: CacheImg(AppConsts.imageUrl + imageUrl)),
              ),

              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: Container(color: c.primary.withValues(alpha: 0.4)),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "$from  ⇄  $to",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: c.onPrimary,
                          fontSize: AppConsts.xlg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "Thu, Oct 16 - Sun, Oct 19",
                        style: TextStyle(
                          color: c.onPrimary,
                          fontSize: AppConsts.lg,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Starting From ",
                            style: TextStyle(
                              color: c.onPrimary,
                              fontSize: AppConsts.normal,
                            ),
                          ),
                          Text(
                            " $price",
                            style: TextStyle(
                              color: c.secondary,
                              fontSize: AppConsts.xxlg + 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

