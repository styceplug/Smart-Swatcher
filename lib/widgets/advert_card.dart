import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class AdvertItem {
  final String title;
  final String subtitle;
  final String imageAsset;
  final Color backgroundColor;
  final List<Color> gradientColors;

  AdvertItem({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.backgroundColor = const Color(0XFFFDE5E5),
    this.gradientColors = const [Color(0XFFE6657A), Color(0XFFB23A50)],
  });
}

class AdvertCard extends StatelessWidget {
  final AdvertItem item;

  const AdvertCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.height150,
      width: Dimensions.screenWidth,
      // margin: EdgeInsets.only(right: Dimensions.width20),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // LEFT SIDE
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          // RIGHT SIDE
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: DecorationImage(
                alignment: Alignment.bottomCenter,
                scale: 1.5,
                image: AssetImage(item.imageAsset),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvertCarousel extends StatefulWidget {
  final List<AdvertItem> adverts;

  const AdvertCarousel({Key? key, required this.adverts}) : super(key: key);

  @override
  State<AdvertCarousel> createState() => _AdvertCarouselState();
}

class _AdvertCarouselState extends State<AdvertCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable Adverts
        SizedBox(
          height: Dimensions.height100*1.7,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.adverts.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return AdvertCard(item: widget.adverts[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.adverts.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 10,
              width: isActive ? 20 : 10,
              decoration: BoxDecoration(
                color: isActive ? Colors.pink : Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
            );
          }),
        ),
      ],
    );
  }
}