import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/card_models.dart';
import '../../utils/card_utils.dart';

class HC5ImageCard extends StatelessWidget {
  final ContextualCard card;

  const HC5ImageCard({
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
        margin: const EdgeInsets.only(bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: card.bgImage != null
              ? CachedNetworkImage(
                  imageUrl: card.bgImage!.imageUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                )
              : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        ),
      ),
    );
  }
}
