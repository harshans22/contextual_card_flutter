class ContextualCardsResponse {
  final List<CardGroup> hcGroups;

  ContextualCardsResponse({required this.hcGroups});

  factory ContextualCardsResponse.fromJson(List<dynamic> json) {
    return ContextualCardsResponse(
      hcGroups: json.expand((group) => (group['hc_groups'] as List).map((hcGroup) => CardGroup.fromJson(hcGroup))).toList(),
    );
  }
}

class CardGroup {
  final int id;
  final String name;
  final String designType;
  final List<ContextualCard> cards;
  final bool isScrollable;
  final double height;
  final bool isFullWidth;
  final int level;

  CardGroup({
    required this.id,
    required this.name,
    required this.designType,
    required this.cards,
    required this.isScrollable,
    required this.height,
    required this.isFullWidth,
    required this.level,
  });

  factory CardGroup.fromJson(Map<String, dynamic> json) {
    return CardGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      designType: json['design_type'] ?? '',
      cards: (json['cards'] as List? ?? [])
          .map((card) => ContextualCard.fromJson(card))
          .toList(),
      isScrollable: json['is_scrollable'] ?? false,
      height: (json['height'] ?? 0).toDouble(),
      isFullWidth: json['is_full_width'] ?? false,
      level: json['level'] ?? 0,
    );
  }
}

class ContextualCard {
  final int id;
  final String name;
  final String slug;
  final String? title;
  final FormattedText? formattedTitle;
  final String? description;
  final FormattedText? formattedDescription;
  final CardImage? icon;
  final String? url;
  final CardImage? bgImage;
  final String? bgColor;
  final Gradient? bgGradient;
  final List<CallToAction> cta;
  final bool isDisabled;
  final double? iconSize;

  ContextualCard({
    required this.id,
    required this.name,
    required this.slug,
    this.title,
    this.formattedTitle,
    this.description,
    this.formattedDescription,
    this.icon,
    this.url,
    this.bgImage,
    this.bgColor,
    this.bgGradient,
    required this.cta,
    required this.isDisabled,
    this.iconSize,
  });

  factory ContextualCard.fromJson(Map<String, dynamic> json) {
    return ContextualCard(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      title: json['title'],
      formattedTitle: json['formatted_title'] != null
          ? FormattedText.fromJson(json['formatted_title'])
          : null,
      description: json['description'],
      formattedDescription: json['formatted_description'] != null
          ? FormattedText.fromJson(json['formatted_description'])
          : null,
      icon: json['icon'] != null ? CardImage.fromJson(json['icon']) : null,
      url: json['url'],
      bgImage: json['bg_image'] != null ? CardImage.fromJson(json['bg_image']) : null,
      bgColor: json['bg_color'],
      bgGradient: json['bg_gradient'] != null
          ? Gradient.fromJson(json['bg_gradient'])
          : null,
      cta: (json['cta'] as List? ?? [])
          .map((cta) => CallToAction.fromJson(cta))
          .toList(),
      isDisabled: json['is_disabled'] ?? false,
      iconSize: json['icon_size']?.toDouble(),
    );
  }
}

class FormattedText {
  final String text;
  final String align;
  final List<TextEntity> entities;

  FormattedText({
    required this.text,
    required this.align,
    required this.entities,
  });

  factory FormattedText.fromJson(Map<String, dynamic> json) {
    return FormattedText(
      text: json['text'] ?? '',
      align: json['align'] ?? 'left',
      entities: (json['entities'] as List? ?? [])
          .map((entity) => TextEntity.fromJson(entity))
          .toList(),
    );
  }
}

class TextEntity {
  final String text;
  final String? color;
  final String? url;
  final String? fontStyle;
  final String? fontFamily;
  final double? fontSize;
  final String type;

  TextEntity({
    required this.text,
    this.color,
    this.url,
    this.fontStyle,
    this.fontFamily,
    this.fontSize,
    required this.type,
  });

  factory TextEntity.fromJson(Map<String, dynamic> json) {
    return TextEntity(
      text: json['text'] ?? '',
      color: json['color'],
      url: json['url'],
      fontStyle: json['font_style'],
      fontFamily: json['font_family'],
      fontSize: json['font_size']?.toDouble(),
      type: json['type'] ?? 'generic_text',
    );
  }
}

class CallToAction {
  final String text;
  final String? bgColor;
  final String? url;
  final String? textColor;
  final String type;
  final bool isCircular;
  final bool isSecondary;
  final double strokeWidth;

  CallToAction({
    required this.text,
    this.bgColor,
    this.url,
    this.textColor,
    required this.type,
    required this.isCircular,
    required this.isSecondary,
    required this.strokeWidth,
  });

  factory CallToAction.fromJson(Map<String, dynamic> json) {
    return CallToAction(
      text: json['text'] ?? '',
      bgColor: json['bg_color'],
      url: json['url'],
      textColor: json['text_color'],
      type: json['type'] ?? 'normal',
      isCircular: json['is_circular'] ?? false,
      isSecondary: json['is_secondary'] ?? false,
      strokeWidth: (json['stroke_width'] ?? 0).toDouble(),
    );
  }
}

class Gradient {
  final List<String> colors;
  final double angle;

  Gradient({required this.colors, required this.angle});

  factory Gradient.fromJson(Map<String, dynamic> json) {
    return Gradient(
      colors: List<String>.from(json['colors'] ?? []),
      angle: (json['angle'] ?? 0).toDouble(),
    );
  }
}

class CardImage {
  final String imageType;
  final String? imageUrl;
  final String? assetType;
  final double aspectRatio;

  CardImage({
    required this.imageType,
    this.imageUrl,
    this.assetType,
    required this.aspectRatio,
  });

  factory CardImage.fromJson(Map<String, dynamic> json) {
    return CardImage(
      imageType: json['image_type'] ?? 'ext',
      imageUrl: json['image_url'],
      assetType: json['asset_type'],
      aspectRatio: (json['aspect_ratio'] ?? 1.0).toDouble(),
    );
  }
}

enum DesignType {
  smallDisplayCard('HC1'),
  bigDisplayCard('HC3'),
  imageCard('HC5'),
  smallCardWithArrow('HC6'),
  dynamicWidthCard('HC9');

  const DesignType(this.value);
  final String value;

  static DesignType fromString(String value) {
    return DesignType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DesignType.smallDisplayCard,
    );
  }
}
