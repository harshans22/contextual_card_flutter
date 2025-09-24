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
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSliding = false;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    
    // Slide animation for the action buttons
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.25, 0),
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for removing the card
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    if (_isRemoving) return; // Don't allow interaction while removing
    
    setState(() {
      _isSliding = !_isSliding;
    });
    if (_isSliding) {
      _slideAnimationController.forward();
    } else {
      _slideAnimationController.reverse();
    }
  }

  void _handleTapToClose() {
    if (_isSliding && !_isRemoving) {
      setState(() {
        _isSliding = false;
      });
      _slideAnimationController.reverse();
    }
  }

  Future<void> _handleRemindLater() async {
    if (_isRemoving) return; // Prevent double taps
    
    setState(() {
      _isRemoving = true;
    });

    try {
      // Store the card for remind later
      await StorageService.remindLaterCard(widget.card.slug);
      
      // Start fade out animation
      await _fadeAnimationController.forward();
      
      // Call the parent's onRemove callback
      if (mounted) {
        widget.onRemove?.call();
      }
    } catch (e) {
      // Handle error - maybe show a snackbar
      if (mounted) {
        setState(() {
          _isRemoving = false;
          _isSliding = false;
        });
        _slideAnimationController.reverse();
        _fadeAnimationController.reverse();
      }
    }
  }

  Future<void> _handleDismiss() async {
    if (_isRemoving) return; // Prevent double taps
    
    setState(() {
      _isRemoving = true;
    });

    try {
      // Permanently dismiss the card
      await StorageService.dismissCard(widget.card.slug);
      
      // Start fade out animation
      await _fadeAnimationController.forward();
      
      // Call the parent's onRemove callback
      if (mounted) {
        widget.onRemove?.call();
      }
    } catch (e) {
      // Handle error - maybe show a snackbar
      if (mounted) {
        setState(() {
          _isRemoving = false;
          _isSliding = false;
        });
        _slideAnimationController.reverse();
        _fadeAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.25;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () {
          if (_isRemoving) return;
          
          if (_isSliding) {
            _handleTapToClose();
          } else if (widget.card.url != null) {
            CardUtils.handleDeepLink(widget.card.url!);
          }
        },
        onLongPress: _handleLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              // Action buttons positioned on the left side
              if (_isSliding)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: buttonWidth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        // Remind Later Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _isRemoving ? null : _handleRemindLater,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _isRemoving 
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _isRemoving 
                                          ? Colors.grey[400]
                                          : const Color(0xFFFF9800),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'remind later',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isRemoving ? Colors.grey : Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Dismiss Now Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _isRemoving ? null : _handleDismiss,
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _isRemoving 
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _isRemoving 
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'dismiss now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isRemoving ? Colors.grey : Colors.black,
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
                ),
              
              // Main card with slide animation
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: double.infinity,
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
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title section
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
                            
                            // CTA Buttons at bottom
                            if (widget.card.cta.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widget.card.cta.map((cta) => Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  child: ElevatedButton(
                                    onPressed: _isRemoving ? null : () {
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
                                )).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
