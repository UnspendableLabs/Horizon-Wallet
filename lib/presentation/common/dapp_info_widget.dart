import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

bool _isValidFaviconUrl(String? url) {
  if (url == null || url.isEmpty) return false;

  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

class DAppInfoWidget extends StatelessWidget {
  final String title;
  final String? dappUrl;
  final String? dappTitle;
  final String? dappFavicon;

  const DAppInfoWidget({
    super.key,
    required this.title,
    this.dappUrl,
    this.dappTitle,
    this.dappFavicon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _isValidFaviconUrl(dappFavicon)
                ? CachedNetworkImage(
                    imageUrl: dappFavicon!,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return AppIcons.shieldIcon(
                        context: context,
                        width: 32,
                        height: 32,
                        color: Colors.black,
                      );
                    },
                  )
                : AppIcons.shieldIcon(
                    context: context,
                    width: 32,
                    height: 32,
                    color: Colors.black,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (dappTitle != null && dappTitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  dappTitle!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (dappUrl != null) ...[
                const SizedBox(height: 2),
                Text(
                  dappUrl!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
