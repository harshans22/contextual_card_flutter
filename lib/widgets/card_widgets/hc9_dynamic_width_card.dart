import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/card_models.dart';
import '../../utils/color_utils.dart';
import '../../utils/card_utils.dart';

class HC9DynamicWidthCard extends StatelessWidget {
  final ContextualCard card;
  final double height;

  const HC9DynamicWidthCard({
    super.key,
    required this.card,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final width = card.bgImage != null 
        ? height * card.bgImage!.aspectRatio
        : height * 0.75;

    return GestureDetector(
      onTap: () {
        if (card.url != null) {
          CardUtils.handleDeepLink(card.url!);
        }
      },
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: card.bgGradient != null
              ? ColorUtils.createGradient(
                  card.bgGradient!.colors,
                  card.bgGradient!.angle,
                )
              : null,
          color: card.bgColor != null
              ? ColorUtils.fromHex(card.bgColor)
              : null,
        ),
        child: Stack(
          children: [
            if (card.bgImage != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: card.bgImage!.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
