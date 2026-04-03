import 'package:flutter/material.dart';

class TopicStyle {
  const TopicStyle({
    required this.icon,
    required this.primaryColor,
    required this.accentColor,
  });

  final IconData icon;
  final Color primaryColor;
  final Color accentColor;
}

TopicStyle topicStyleFor(String topicId) {
  return _topicStyles[topicId] ?? _fallbackStyle;
}

const _fallbackStyle = TopicStyle(
  icon: Icons.forum_rounded,
  primaryColor: Color(0xFF0F6A67),
  accentColor: Color(0xFFC96A33),
);

const _topicStyles = <String, TopicStyle>{
  'religion': TopicStyle(
    icon: Icons.temple_hindu_rounded,
    primaryColor: Color(0xFF5B3F8C),
    accentColor: Color(0xFFE5B95C),
  ),
  'science': TopicStyle(
    icon: Icons.biotech_rounded,
    primaryColor: Color(0xFF146356),
    accentColor: Color(0xFF7ED7C1),
  ),
  'philosophy': TopicStyle(
    icon: Icons.psychology_alt_rounded,
    primaryColor: Color(0xFF2A4B7C),
    accentColor: Color(0xFFD3B1FF),
  ),
  'politics': TopicStyle(
    icon: Icons.account_balance_rounded,
    primaryColor: Color(0xFF8A3B34),
    accentColor: Color(0xFFF1B28B),
  ),
  'ethics': TopicStyle(
    icon: Icons.balance_rounded,
    primaryColor: Color(0xFF315C5B),
    accentColor: Color(0xFFF4C77D),
  ),
  'technology': TopicStyle(
    icon: Icons.memory_rounded,
    primaryColor: Color(0xFF0F597A),
    accentColor: Color(0xFF91D6F6),
  ),
  'history': TopicStyle(
    icon: Icons.menu_book_rounded,
    primaryColor: Color(0xFF6E4D37),
    accentColor: Color(0xFFDDB58C),
  ),
  'culture': TopicStyle(
    icon: Icons.public_rounded,
    primaryColor: Color(0xFF8C2F66),
    accentColor: Color(0xFFF59AC6),
  ),
  'sports': TopicStyle(
    icon: Icons.sports_soccer_rounded,
    primaryColor: Color(0xFF2D6A36),
    accentColor: Color(0xFF9FE58B),
  ),
  'economics': TopicStyle(
    icon: Icons.query_stats_rounded,
    primaryColor: Color(0xFF6A551E),
    accentColor: Color(0xFFFFD86F),
  ),
};
