import 'package:flutter/material.dart';

enum SlotKind {
  seat('좌석', Icons.event_seat_rounded, Color(0xFF4D8CC8)),
  kiosk('매점', Icons.local_cafe_rounded, Color(0xFFD1843C));

  const SlotKind(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
