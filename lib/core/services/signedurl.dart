import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:s3_storage/s3_storage.dart';
import 'package:vd_customer_app/core/services/api_services.dart';

final Map<String, String> signedUrls = {};

String _wrapS3KeyAsUrl(String rawKey) {
  var k = rawKey.trim();
  if (k.isEmpty) return k;
  if (!k.startsWith('/')) k = '/$k';
  return 'https://s3.local$k';
}

Future<String> generateSignedUrl(String rawS3Url) async {
  final raw = rawS3Url.trim();
  if (raw.isEmpty) return "";
  final cached = signedUrls[raw];
  if (cached != null && cached.isNotEmpty) return cached;

  try {
    final uri = Uri.parse(raw);
    final isHttp =
        uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isHttp) {
      final qp = uri.queryParameters;
      if (qp.containsKey('X-Amz-Signature') ||
          qp.containsKey('X-Amz-Algorithm')) {
        signedUrls[raw] = raw;
        return raw;
      }
    }

    try {
      final requestUrl = isHttp ? raw : _wrapS3KeyAsUrl(raw);
      final presignResponse = await Api.post('getPublicPresignedUrls', {
        "data": {
          "urls": [requestUrl],
        },
      });
      final ok =
          presignResponse['success'] == true ||
          presignResponse['dataResponse']?['returnCode'] == 0;
      if (ok) {
        final results = presignResponse['data'];
        if (results is List && results.isNotEmpty) {
          Map<String, dynamic>? hit;
          for (final r in results) {
            if (r is Map<String, dynamic> && r['originalUrl'] == requestUrl) {
              hit = r;
              break;
            }
          }
          hit ??= results.first is Map<String, dynamic>
              ? (results.first as Map<String, dynamic>)
              : null;
          final presignedUrl = hit?['presignedUrl'];
          if (presignedUrl is String && presignedUrl.isNotEmpty) {
            signedUrls[raw] = presignedUrl;
            return presignedUrl;
          }
        }
      }
    } catch (_) {}

    final region = dotenv.env['AWS_REGION']?.trim();
    final envBucket = dotenv.env['S3_BUCKET']?.trim();
    final accessKey = dotenv.env['AWS_ACCESS_KEY_ID']?.trim();
    final secretKey = dotenv.env['AWS_SECRET_ACCESS_KEY']?.trim();

    final bucket = (envBucket != null && envBucket.isNotEmpty)
        ? envBucket
        : (uri.scheme == 's3' ? uri.host.trim() : null);

    if (region == null ||
        region.isEmpty ||
        bucket == null ||
        bucket.isEmpty ||
        accessKey == null ||
        accessKey.isEmpty ||
        secretKey == null ||
        secretKey.isEmpty) {
      if (isHttp) {
        signedUrls[raw] = raw;
        return raw;
      }
      return "";
    }

    String objectKey = uri.path;
    if (objectKey.startsWith('/')) objectKey = objectKey.substring(1);
    if (objectKey.isEmpty) objectKey = raw;
    if (objectKey.startsWith('/')) objectKey = objectKey.substring(1);

    final isPathStyleS3 =
        isHttp &&
        (uri.host == 's3.amazonaws.com' || uri.host.startsWith('s3.'));
    if (isPathStyleS3 && objectKey.startsWith('$bucket/')) {
      objectKey = objectKey.substring(bucket.length + 1);
    }

    if (objectKey.isEmpty) return "";

    final s3Storage = S3Storage(
      endPoint: "s3.$region.amazonaws.com",
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );
    final presignedUrl = await s3Storage.presignedGetObject(
      bucket,
      objectKey,
      expires: 3600,
    );
    signedUrls[raw] = presignedUrl;

    return presignedUrl;
  } catch (e) {
    log("Error generating signed URL: $e");
    return "";
  }
}
