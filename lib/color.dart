import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

// Modern Editor (Dark / Minimalist Style)
const backgroundStartColor = Color(0xFF1E1E1E); // Deep charcoal background
const backgroundEndColor = Color(0xFF252525);   // Slightly lighter surface for contrast
const regionColor = Color(0xFF2D2D2D);          // Sidebar / Activity Bar Area
const borderColor = Color(0xFF3F3F46);          // Subtle UI border
const innerBorderColor = Color(0xFF6B7280);     // More defined inner borders
const iconColor = Color(0xFFE5E7EB);            // Light grey icons for visibility
const disabledIconColor = Color(0xFF5D6675);    // Muted grey for disabled state

// Accent for highlights (verses, selected items)
const accentBlue = Color(0xFF0073FF);           // Apple-style Blue retained
const normalColor = Color(0xFFCBD5E1);          // Near-white for primary text/icons

// State colors
const hoverColor = Color(0xFF374151);           // Darker grey hover
const altHoverColor = Color(0xFF2F2F2F);        // Alternate hover shade
const selectedColor = Color(0xFF1F2937);        // Darker tint for selection
const selectedBorderColor = accentBlue;         // Consistent blue border highlight

// Biblical text color
const kAccentBlue = accentBlue;
const kTextGrey = Color(0xFF9CA3AF);            // Readable grey for secondary text
const kTextWhite = Color(0xFFD1D5DB);           // Near-white for readability
const kJesusRed = Color(0xFFEF4444);            // Bright red for emphasis
const kStrongColor = Color(0xFF10B981);         // Vibrant green for strong text

final buttonColors = WindowButtonColors(
  iconNormal: normalColor,
  mouseOver: const Color(0xFF374151),           // Subtle hover background
  mouseDown: const Color(0xFF4B5563),
  iconMouseOver: accentBlue,                    // Glow blue on hover
  iconMouseDown: accentBlue,
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFDC2626),           // Classic red close hover
  mouseDown: const Color(0xFFB91C1C),
  iconNormal: normalColor,
  iconMouseOver: Colors.white,
);
