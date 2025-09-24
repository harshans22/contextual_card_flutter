import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/card_models.dart';
import '../../utils/color_utils.dart';
import '../../utils/text_utils.dart';
import '../../utils/card_utils.dart';

class HC6SmallCardWithArrow extends StatelessWidget {
  final ContextualCard card;

  const HC6SmallCardWithArrow({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (card.url != null) {
          CardUtils.handleDeepLink(card.url!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ColorUtils.fromHex(card.bgColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (card.icon != null) ...[
              SizedBox(
                width: card.iconSize ?? 24,
                height: card.iconSize ?? 24,
                child: CachedNetworkImage(
                  imageUrl: card.icon!.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 16),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _buildTitle(),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTitle() {
    // First try formatted title
    if (card.formattedTitle != null) {
      final formattedWidget = TextUtils.buildFormattedText(
        card.formattedTitle!,
        fallbackText: card.title,
        defaultFontSize: 14,
        defaultColor: Colors.black,
        defaultFontWeight: FontWeight.w600,
      );
      
      // Check if the widget has content
      if (formattedWidget is! SizedBox) {
        return formattedWidget;
      }
    }
    
    // Fallback to simple title
    return TextUtils.buildSimpleText(
      card.title,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }
}
