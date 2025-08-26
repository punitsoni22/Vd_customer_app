import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final double? width;
  final double? height;
  const ImageContainer({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage("https://picsum.photos/400/300"),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.green),
      ),
      height: height ?? 205,
      width: width ?? double.infinity,
    );
  }
}
