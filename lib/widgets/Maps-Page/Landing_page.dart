import 'dart:ui';

import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({
    super.key,
    this.image,
  });

  final Image? image;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/BestPhoenix.png'),
              fit: BoxFit.contain,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topRight,
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                  onTap: () {
                    // Handle cross icon press event here
                  },
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: image?.image ??
                            const AssetImage('assets/images/wolf.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
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
