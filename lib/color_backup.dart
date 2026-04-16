import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

// Modern Editor (Light / Minimalist Style)
const backgroundStartColor = Color(0xFFFCF7F4); // Soft Off-White Background
const backgroundEndColor = Color(0xFFFCF7F4);   // Slightly deeper surface for contrast
const regionColor = Color(0xFFF2F2F2);          // Sidebar / Activity Bar Area
const borderColor = Color(0xFFD1D5DB);          // Subtle UI border
const innerBorderColor = Color(0xFF9CA3AF);     // Slightly more defined inner borders
const iconColor = Color(0xFF4B5563);            // Muted dark grey icons
const disabledIconColor = Color(0xFF9CA3AF);    // Lighter grey for disabled state

// Accent for highlights (verses, selected items)
const accentBlue = Color(0xFF0073FF);           // Kept original Apple-style Blue
const normalColor = Color(0xFF1B1818);          // Dark grey for primary text/icons

// State colors
const hoverColor = Color(0xFFEDF1F6);           // Very light blueish-grey hover
const altHoverColor = Color(0xFFF3EEEC);           // Very light blueish-grey hover
const selectedColor = Color(0xFFEDE6E2);         // Soft blue tint for selection
const selectedBorderColor = accentBlue;   // Consistent blue border highlight

// Biblical text color
const kAccentBlue = accentBlue;
const kTextGrey = Color(0xFF6B7280);            // Readable grey for secondary text
const kTextWhite = Color(0xFF111827);           // Replaced White with near-black for readability
const kJesusRed = Color(0xFFB91C1C);            // Deepened red for better contrast on light BG
const kStrongColor = Color(0xFF059669);         // Deepened green for better visibility

final buttonColors = WindowButtonColors(
  iconNormal: normalColor,
  // Subtle hover background for the window controls
  mouseOver: const Color(0xFFE5E7EB),
  mouseDown: const Color(0xFFD1D5DB),
  iconMouseOver: accentBlue,       // Glow blue on hover
  iconMouseDown: accentBlue,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFEF4444),           // Classic red close hover
  mouseDown: const Color(0xFFB91C1C),
  iconNormal: normalColor,
  iconMouseOver: Colors.white,
);