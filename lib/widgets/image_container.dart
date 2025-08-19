import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer({super.key});

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
      height: 205,
      width: double.infinity,
    );
  }
}
