import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
IconData getAmiconFromEmoji(String? emoji) {
  switch(emoji) {
    case '🔥': return Amicons.remix_fire_fill;
    case '🌊': return Amicons.remix_flood_fill;
    case '🏚️': return Amicons.remix_earthquake_fill;
    case '🌪️': return Amicons.remix_tornado_fill;
    case '⛰️': return Amicons.remix_landscape_fill;
    case '⚠️': return Amicons.remix_error_warning_fill;
    case '🚨': return Amicons.remix_alarm_warning_fill;
    case '🚗': return Amicons.remix_car_fill;
    case '💥': return Amicons.remix_fire_fill;
    case '🏗️': return Amicons.remix_building_fill;
    case '☢️': return Amicons.remix_skull2_fill;
    case '☣️': return Amicons.remix_skull2_fill;
    default: return Amicons.remix_fire_fill;
  }
}
