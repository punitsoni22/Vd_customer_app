import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:s3_storage/s3_storage.dart';

// Cache for signed URLs (so we don’t regenerate if already done)
final Map<String, String> signedUrls = {};

Future<String> generateSignedUrl(String rawS3Url) async {
  if (rawS3Url.isEmpty) return "";

  try {
    // Parse the incoming S3 URL
    final uri = Uri.parse(rawS3Url);
    final objectKey = uri.path.substring(
      1,
    ); // same as JS: url.pathname.slice(1)

    if (objectKey.isEmpty) {
      throw Exception("Invalid S3 URL");
    }

    // Read environment variables (same as import.meta.env in JS)
    final region = dotenv.env['AWS_REGION']!;
    final bucket = dotenv.env['S3_BUCKET']!;
    final accessKey = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;

    // Create S3 client
    final s3Storage = S3Storage(
      endPoint: "s3.$region.amazonaws.com",
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );

    // Generate a presigned GET URL (same as getSignedUrl in JS)
    final presignedUrl = await s3Storage.presignedGetObject(
      bucket,
      objectKey,
      expires: 300,
    );

    // Cache the result
    signedUrls[rawS3Url] = presignedUrl;

    log("Successfully generated signed URL for: $objectKey");
    return presignedUrl;
  } catch (e) {
    log("Error generating signed URL: $e");
    // Get.snackbar(
    //   "Error",
    //   "Could not load image preview",
    //   backgroundColor: const Color(0xFFE53935),
    // ); // red
    return "";
  }
}
