import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIconMapper {
  static final Map<String, IconData> _iconMap = {
    'icon_food': FontAwesomeIcons.utensils,
    'icon_transport': FontAwesomeIcons.bus,
    'icon_shopping': FontAwesomeIcons.cartShopping,
    'icon_bills': FontAwesomeIcons.fileInvoice,
    'icon_entertainment': FontAwesomeIcons.film,
    'icon_health': FontAwesomeIcons.heartPulse,
    'icon_other': FontAwesomeIcons.ellipsis,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null || !_iconMap.containsKey(iconName)) {
      return FontAwesomeIcons.question;
    }
    return _iconMap[iconName]!;
  }
}
