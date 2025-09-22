import 'package:contextual_card_flutter/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/card_models.dart';
import '../../utils/color_utils.dart';
import '../../utils/text_utils.dart';
import '../../utils/card_utils.dart';

class HC3BigDisplayCard extends StatefulWidget {
  final ContextualCard card;
  final VoidCallback? onRemove;

  const HC3BigDisplayCard({
    super.key,
    required this.card,
    this.onRemove,
  });

  @override
  State<HC3BigDisplayCard> createState() => _HC3BigDisplayCardState();
}

class _HC3BigDisplayCardState extends State<HC3BigDisplayCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSliding = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    setState(() {
      _isSliding = !_isSliding;
    });
    if (_isSliding) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _handleRemindLater() async {
    await StorageService.remindLaterCard(widget.card.slug);
    _animationController.reverse();
    setState(() {
      _isSliding = false;
    });
    widget.onRemove?.call();
  }

  Future<void> _handleDismiss() async {
    await StorageService.dismissCard(widget.card.slug);
    _animationController.reverse();
    setState(() {
      _isSliding = false;
    });
    widget.onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isSliding && widget.card.url != null) {
          CardUtils.handleDeepLink(widget.card.url!);
        }
      },
      onLongPress: _handleLongPress,
      child: Stack(
        children: [
          // Action buttons (shown when sliding)
          if (_isSliding)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 120,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleRemindLater,
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule, color: Colors.white, size: 20),
                            SizedBox(height: 4),
                            Text(
                              'remind\nlater',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _handleDismiss,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.close, color: Colors.white, size: 20),
                            SizedBox(height: 4),
                            Text(
                              'dismiss\nnow',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main card
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: widget.card.bgGradient != null
                    ? ColorUtils.createGradient(
                        widget.card.bgGradient!.colors,
                        widget.card.bgGradient!.angle,
                      )
                    : null,
                color: widget.card.bgColor != null
                    ? ColorUtils.fromHex(widget.card.bgColor)
                    : null,
              ),
              child: Stack(
                children: [
                  if (widget.card.bgImage != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: widget.card.bgImage!.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.card.formattedTitle != null)
                          TextUtils.buildFormattedText(
                            widget.card.formattedTitle!,
                            defaultFontSize: 30,
                            defaultColor: Colors.white,
                            defaultFontWeight: FontWeight.w600,
                          )
                        else if (widget.card.title != null)
                          TextUtils.buildSimpleText(
                            widget.card.title,
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        const Spacer(),
                        if (widget.card.cta.isNotEmpty)
                          ...widget.card.cta.map((cta) => Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (cta.url != null) {
                                      CardUtils.handleDeepLink(cta.url!);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorUtils.fromHex(cta.bgColor) != Colors.transparent
                                        ? ColorUtils.fromHex(cta.bgColor)
                                        : Colors.black,
                                    foregroundColor: ColorUtils.fromHex(cta.textColor) != Colors.transparent
                                        ? ColorUtils.fromHex(cta.textColor)
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(cta.isCircular ? 25 : 8),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    cta.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
