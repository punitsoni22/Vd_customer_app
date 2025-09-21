import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:s3_storage/s3_storage.dart';

final Map<String, String> signedUrls = {};

Future<String> generateSignedUrl(String rawS3Url) async {
  if (rawS3Url.isEmpty) return "";

  try {
    final uri = Uri.parse(rawS3Url);
    final objectKey = uri.path.substring(1);

    if (objectKey.isEmpty) {
      throw Exception("Invalid S3 URL");
    }
    final region = dotenv.env['AWS_REGION']!;
    final bucket = dotenv.env['S3_BUCKET']!;
    final accessKey = dotenv.env['AWS_ACCESS_KEY_ID']!;
    final secretKey = dotenv.env['AWS_SECRET_ACCESS_KEY']!;
    final s3Storage = S3Storage(
      endPoint: "s3.$region.amazonaws.com",
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );
    final presignedUrl = await s3Storage.presignedGetObject(
      bucket,
      objectKey,
      expires: 300,
    );

    signedUrls[rawS3Url] = presignedUrl;
    return presignedUrl;
  } catch (e) {
    log("Error generating signed URL: $e");
    return "";
  }
}
