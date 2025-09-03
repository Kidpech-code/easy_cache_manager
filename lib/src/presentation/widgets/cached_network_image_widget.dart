import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../cache_manager.dart';

/// A widget that displays cached network images using CacheManager
/// Note: This widget doesn't depend on the cached_network_image package to keep dependencies light.
class CachedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final CacheManager cacheManager;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Duration? maxAge;
  final Map<String, String>? headers;
  final bool forceRefresh;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    required this.cacheManager,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.width,
    this.height,
    this.maxAge,
    this.headers,
    this.forceRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: cacheManager.getBytes(imageUrl,
          maxAge: maxAge, headers: headers, forceRefresh: forceRefresh),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder?.call(context, imageUrl) ??
              _defaultPlaceholder(context, imageUrl);
        }

        if (snapshot.hasError) {
          return errorWidget?.call(context, imageUrl, snapshot.error) ??
              _defaultErrorWidget(context, imageUrl, snapshot.error);
        }

        if (snapshot.hasData) {
          return Image.memory(snapshot.data!,
              fit: fit, width: width, height: height);
        }

        return _defaultPlaceholder(context, imageUrl);
      },
    );
  }

  Widget _defaultPlaceholder(BuildContext context, String url) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _defaultErrorWidget(BuildContext context, String url, dynamic error) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
      child: const Center(child: Icon(Icons.error, color: Colors.red)),
    );
  }
}
