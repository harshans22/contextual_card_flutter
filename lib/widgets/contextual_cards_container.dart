import 'package:contextual_card_flutter/services/storage_services.dart';
import 'package:flutter/material.dart';
import '../models/card_models.dart';
import '../services/api_service.dart';
import 'card_widgets/hc1_small_display_card.dart';
import 'card_widgets/hc3_big_display_card.dart';
import 'card_widgets/hc5_image_card.dart';
import 'card_widgets/hc6_small_card_with_arrow.dart';
import 'card_widgets/hc9_dynamic_width_card.dart';

class ContextualCardsContainer extends StatefulWidget {
  const ContextualCardsContainer({super.key});

  @override
  State<ContextualCardsContainer> createState() => _ContextualCardsContainerState();
}

class _ContextualCardsContainerState extends State<ContextualCardsContainer> {
  List<CardGroup> _cardGroups = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCards();
    _clearRemindLaterOnAppStart();
  }

  Future<void> _clearRemindLaterOnAppStart() async {
    await StorageService.clearRemindLaterCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final cardGroups = await ApiService.fetchContextualCards();
      final filteredGroups = await _filterCards(cardGroups);

      setState(() {
        _cardGroups = filteredGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<List<CardGroup>> _filterCards(List<CardGroup> cardGroups) async {
    final filteredGroups = <CardGroup>[];

    for (final group in cardGroups) {
      final filteredCards = <ContextualCard>[];

      for (final card in group.cards) {
        final isDismissed = await StorageService.isCardDismissed(card.slug);
        if (!isDismissed) {
          filteredCards.add(card);
        }
      }

      if (filteredCards.isNotEmpty) {
        filteredGroups.add(CardGroup(
          id: group.id,
          name: group.name,
          designType: group.designType,
          cards: filteredCards,
          isScrollable: group.isScrollable,
          height: group.height,
          isFullWidth: group.isFullWidth,
          level: group.level,
        ));
      }
    }

    // Sort by level
    filteredGroups.sort((a, b) => a.level.compareTo(b.level));
    return filteredGroups;
  }

  void _onCardRemoved() {
    _loadCards();
  }

  Widget _buildCardGroup(CardGroup cardGroup) {
    final designType = DesignType.fromString(cardGroup.designType);

    switch (designType) {
      case DesignType.smallDisplayCard:
        return _buildScrollableCards(cardGroup);
      case DesignType.bigDisplayCard:
        return _buildSingleCard(cardGroup);
      case DesignType.imageCard:
        return _buildSingleCard(cardGroup);
      case DesignType.smallCardWithArrow:
        return _buildSingleCard(cardGroup);
      case DesignType.dynamicWidthCard:
        return _buildScrollableCards(cardGroup);
    }
  }

  Widget _buildScrollableCards(CardGroup cardGroup) {
    return Container(
      height: cardGroup.height > 0 ? cardGroup.height : null,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cardGroup.cards.length,
        itemBuilder: (context, index) {
          final card = cardGroup.cards[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: _buildCard(card, cardGroup.designType, cardGroup.height),
          );
        },
      ),
    );
  }

  Widget _buildSingleCard(CardGroup cardGroup) {
    if (cardGroup.cards.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _buildCard(cardGroup.cards.first, cardGroup.designType, cardGroup.height),
    );
  }

  Widget _buildCard(ContextualCard card, String designType, double groupHeight) {
    switch (designType) {
      case 'HC1':
        return SizedBox(
          width: 320,
          child: HC1SmallDisplayCard(card: card),
        );
      case 'HC3':
        return SizedBox(
          height: 600,
          child: HC3BigDisplayCard(
            card: card,
            onRemove: _onCardRemoved,
          ),
        );
      case 'HC5':
        return HC5ImageCard(card: card);
      case 'HC6':
        return HC6SmallCardWithArrow(card: card);
      case 'HC9':
        return HC9DynamicWidthCard(
          card: card,
          height: groupHeight,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_cardGroups.isEmpty) {
      return const Center(
        child: Text('No cards available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCards,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _cardGroups.length,
        itemBuilder: (context, index) {
          return _buildCardGroup(_cardGroups[index]);
        },
      ),
    );
  }
}
