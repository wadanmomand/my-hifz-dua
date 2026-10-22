import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads/ads_service.dart';

/// Banner ad footer for map/dashboard screens.
/// Episode stories stay ad-free (Families rule).
class BannerAdFooter extends StatefulWidget {
  const BannerAdFooter({super.key});

  @override
  State<BannerAdFooter> createState() => _BannerAdFooterState();
}

class _BannerAdFooterState extends State<BannerAdFooter> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _ad = KidsAds.createBanner(onLoaded: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
