import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/card_models.dart';
import '../../utils/color_utils.dart';
import '../../utils/text_utils.dart';
import '../../utils/card_utils.dart';

class HC1SmallDisplayCard extends StatelessWidget {
  final ContextualCard card;
  final VoidCallback? onTap;

  const HC1SmallDisplayCard({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (card.url != null) {
          CardUtils.handleDeepLink(card.url!);
        }
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ColorUtils.fromHex(card.bgColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (card.icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: card.icon!.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (card.formattedTitle != null)
                    TextUtils.buildFormattedText(
                      card.formattedTitle!,
                      defaultFontSize: 14,
                      defaultColor: Colors.black,
                      defaultFontWeight: FontWeight.w600,
                    )
                  else if (card.title != null && card.title!.isNotEmpty)
                    TextUtils.buildSimpleText(
                      card.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  if (card.formattedDescription != null ||
                      (card.description != null && card.description!.isNotEmpty))
                    const SizedBox(height: 2),
                  if (card.formattedDescription != null)
                    TextUtils.buildFormattedText(
                      card.formattedDescription!,
                      defaultFontSize: 12,
                      defaultColor: Colors.grey[600]!,
                    )
                  else if (card.description != null && card.description!.isNotEmpty)
                    TextUtils.buildSimpleText(
                      card.description,
                      fontSize: 12,
                      color: Colors.grey[600]!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
